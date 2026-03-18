/*
Purpose:
- Load HubSpot deals/tickets CSV exports into STG (full-fidelity text copy for audit).
- Produce RAW tables by removing metadata/header rows, doing minimal trim/nullif,
  and normalizing scientific-notation IDs to full text.
- Publish AUDIT views for row-count reconciliation, ID distinct checks,
  normalization collisions, and multi-deal detection.

Input files (manual import source from local disk):
- Data Quality - Deals.csv
- Data Quality - Tickets.csv

Important:
- This script does NOT run COPY/\copy automatically.
- Please import local CSV files into STG tables manually using your SQL client (DBeaver/pgAdmin/psql) before running RAW/AUDIT sections.
- This script intentionally does NOT drop STG tables, so imported data is preserved.
*/

create schema if not exists raw;
create schema if not exists audit;

create or replace function raw.normalize_hubspot_id(id_text text)
returns text
language sql
immutable
as $$
    select
        case
            when id_text is null or btrim(id_text) = '' then null
            when btrim(id_text) ~ '^[+-]?\d+(\.\d+)?([eE][+-]?\d+)?$' then
                trim_scale((btrim(id_text)::numeric))::text
            else btrim(id_text)
        end
$$;

-- ========== STG: DEALS (full text copy for audit) ==========
create table if not exists raw.stg_hubspot_deals_csv (
    deal_id text,
    deal_name text,
    po_number_sales text,
    country_sales text,
    customer_code_sales text,
    first_payment_date_crm text,
    payment_status_sales_crm text,
    total_number_of_items_sales text,
    sales_confirmation_value_sales text,
    ticket_id text,
    deal_owner_first_name text,
    first_name text
);

-- MANUAL STEP (local disk import):
-- 1) Optional: truncate table raw.stg_hubspot_deals_csv;
-- 2) Import local file "Data Quality - Deals.csv" into raw.stg_hubspot_deals_csv (all columns as text, header disabled).
-- Example with psql (run on client machine):
-- \copy raw.stg_hubspot_deals_csv from '/path/to/Data Quality - Deals.csv' with (format csv, header false);

-- ========== STG: TICKETS (full text copy for audit) ==========
create table if not exists raw.stg_hubspot_tickets_csv (
    ticket_id text,
    ticket_name text,
    create_date text,
    type_of_products text,
    customer_code_xn text,
    fob_price text,
    quantity_xn text,
    style_xn text,
    color_xn text,
    deal_id text,
    first_payment_date_crm text,
    payment_status_sales_crm text,
    po_number_sales text,
    ticket_owner text,
    leader_name text
);

-- MANUAL STEP (local disk import):
-- 1) Optional: truncate table raw.stg_hubspot_tickets_csv;
-- 2) Import local file "Data Quality - Tickets.csv" into raw.stg_hubspot_tickets_csv (all columns as text, header disabled).
-- Example with psql (run on client machine):
-- \copy raw.stg_hubspot_tickets_csv from '/path/to/Data Quality - Tickets.csv' with (format csv, header false);

-- Guardrail: stop RAW build when STG has no data.
do $$
begin
    if (select count(*) from raw.stg_hubspot_deals_csv) = 0 then
        raise exception 'raw.stg_hubspot_deals_csv is empty. Please import local CSV before running RAW build.';
    end if;

    if (select count(*) from raw.stg_hubspot_tickets_csv) = 0 then
        raise exception 'raw.stg_hubspot_tickets_csv is empty. Please import local CSV before running RAW build.';
    end if;
end $$;

-- ========== RAW: DEALS ==========
drop table if exists raw.hubspot_deals_raw;
create table raw.hubspot_deals_raw as
select
    raw.normalize_hubspot_id(deal_id) as deal_id,
    nullif(trim(deal_name), '') as deal_name,
    nullif(trim(po_number_sales), '') as po_number_sales,
    nullif(trim(country_sales), '') as country_sales,
    nullif(trim(customer_code_sales), '') as customer_code_sales,
    nullif(trim(first_payment_date_crm), '') as first_payment_date_crm,
    nullif(trim(payment_status_sales_crm), '') as payment_status_sales_crm,
    nullif(trim(total_number_of_items_sales), '') as total_number_of_items_sales,
    nullif(trim(sales_confirmation_value_sales), '') as sales_confirmation_value_sales,
    raw.normalize_hubspot_id(ticket_id) as ticket_id,
    nullif(trim(deal_owner_first_name), '') as deal_owner_first_name,
    nullif(trim(first_name), '') as first_name
from raw.stg_hubspot_deals_csv
where coalesce(trim(deal_id), '') <> ''
  and lower(trim(deal_id)) <> 'deal id'
  and lower(trim(deal_id)) not like 'hubspot import%';

-- Backward-compatibility object name.
drop table if exists raw.hubspot_deals;
alter table raw.hubspot_deals_raw rename to hubspot_deals;

-- ========== RAW: TICKETS ==========
drop table if exists raw.hubspot_tickets_raw;
create table raw.hubspot_tickets_raw as
select
    raw.normalize_hubspot_id(ticket_id) as ticket_id,
    nullif(trim(ticket_name), '') as ticket_name,
    nullif(trim(create_date), '') as create_date,
    nullif(trim(type_of_products), '') as type_of_products,
    nullif(trim(customer_code_xn), '') as customer_code_xn,
    nullif(trim(fob_price), '') as fob_price,
    nullif(trim(quantity_xn), '') as quantity_xn,
    nullif(trim(style_xn), '') as style_xn,
    nullif(trim(color_xn), '') as color_xn,
    nullif(trim(deal_id), '') as deal_id_raw,
    raw.normalize_hubspot_id(deal_id) as deal_id,
    nullif(trim(first_payment_date_crm), '') as first_payment_date_crm,
    nullif(trim(payment_status_sales_crm), '') as payment_status_sales_crm,
    nullif(trim(po_number_sales), '') as po_number_sales,
    nullif(trim(ticket_owner), '') as ticket_owner,
    nullif(trim(leader_name), '') as leader_name
from raw.stg_hubspot_tickets_csv
where coalesce(trim(ticket_id), '') <> ''
  and lower(trim(ticket_id)) <> 'ticket id'
  and lower(trim(ticket_id)) not like 'hubspot import%';

-- Backward-compatibility object name.
drop table if exists raw.hubspot_tickets;
alter table raw.hubspot_tickets_raw rename to hubspot_tickets;

-- ========== AUDIT ==========
create or replace view audit.v_hubspot_row_count_reconciliation as
select 'deals' as dataset,
       (select count(*) from raw.stg_hubspot_deals_csv) as stg_rows,
       (select count(*) from raw.hubspot_deals) as raw_rows,
       (select count(*) from raw.stg_hubspot_deals_csv) - (select count(*) from raw.hubspot_deals) as removed_metadata_rows
union all
select 'tickets' as dataset,
       (select count(*) from raw.stg_hubspot_tickets_csv) as stg_rows,
       (select count(*) from raw.hubspot_tickets) as raw_rows,
       (select count(*) from raw.stg_hubspot_tickets_csv) - (select count(*) from raw.hubspot_tickets) as removed_metadata_rows;

create or replace view audit.v_hubspot_distinct_id_reconciliation as
select 'deals' as dataset,
       (select count(distinct raw.normalize_hubspot_id(deal_id))
        from raw.stg_hubspot_deals_csv
        where coalesce(trim(deal_id), '') <> ''
          and lower(trim(deal_id)) <> 'deal id'
          and lower(trim(deal_id)) not like 'hubspot import%') as stg_distinct_id,
       (select count(distinct deal_id) from raw.hubspot_deals) as raw_distinct_id
union all
select 'tickets' as dataset,
       (select count(distinct raw.normalize_hubspot_id(ticket_id))
        from raw.stg_hubspot_tickets_csv
        where coalesce(trim(ticket_id), '') <> ''
          and lower(trim(ticket_id)) <> 'ticket id'
          and lower(trim(ticket_id)) not like 'hubspot import%') as stg_distinct_id,
       (select count(distinct ticket_id) from raw.hubspot_tickets) as raw_distinct_id;

create or replace view audit.v_hubspot_id_normalization_collisions as
with candidate_ids as (
    select 'deals' as dataset,
           trim(deal_id) as original_id,
           raw.normalize_hubspot_id(deal_id) as normalized_id
    from raw.stg_hubspot_deals_csv
    where coalesce(trim(deal_id), '') <> ''
      and lower(trim(deal_id)) <> 'deal id'
      and lower(trim(deal_id)) not like 'hubspot import%'
    union all
    select 'tickets' as dataset,
           trim(ticket_id) as original_id,
           raw.normalize_hubspot_id(ticket_id) as normalized_id
    from raw.stg_hubspot_tickets_csv
    where coalesce(trim(ticket_id), '') <> ''
      and lower(trim(ticket_id)) <> 'ticket id'
      and lower(trim(ticket_id)) not like 'hubspot import%'
)
select
    dataset,
    normalized_id,
    count(distinct original_id) as distinct_original_ids,
    array_agg(distinct original_id order by original_id) as original_id_examples
from candidate_ids
group by dataset, normalized_id
having count(distinct original_id) > 1;

create or replace view audit.v_hubspot_ticket_multi_deal as
select
    ticket_id,
    count(distinct raw.normalize_hubspot_id(deal_id_piece)) as distinct_deal_count,
    array_agg(distinct raw.normalize_hubspot_id(deal_id_piece) order by raw.normalize_hubspot_id(deal_id_piece)) as deal_ids
from (
    select
        raw.normalize_hubspot_id(ticket_id) as ticket_id,
        nullif(trim(piece), '') as deal_id_piece
    from raw.stg_hubspot_tickets_csv s
    cross join lateral regexp_split_to_table(coalesce(s.deal_id, ''), '\s*[,;|/]\s*') as piece
    where coalesce(trim(ticket_id), '') <> ''
      and lower(trim(ticket_id)) <> 'ticket id'
      and lower(trim(ticket_id)) not like 'hubspot import%'
) t
where deal_id_piece is not null
group by ticket_id
having count(distinct raw.normalize_hubspot_id(deal_id_piece)) > 1;
