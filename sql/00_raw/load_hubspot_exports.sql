/*
Purpose:
- Load HubSpot deals/tickets CSV exports into raw schema for downstream DQ checks.

Input files:
- data/Data Quality - Deals.csv
- data/Data Quality - Tickets.csv

Notes:
- HubSpot export includes 2 metadata lines before the CSV header.
- Avoid `COPY FROM PROGRAM` (often blocked in managed DB / pgAdmin setup).
- This script loads full CSV (header disabled), then removes metadata/header rows in INSERT.
*/

create schema if not exists raw;

create or replace function raw.normalize_hubspot_id(id_text text)
returns text
language sql
immutable
as $$
    select
        case
            when id_text is null or btrim(id_text) = '' then null
            when btrim(id_text) ~ '^[+-]?\d+(\.\d+)?([eE][+-]?\d+)?$' then
                regexp_replace(trim(to_char((btrim(id_text)::numeric), 'FM99999999999999999999999999999999999990')), '\.$', '')
            else btrim(id_text)
        end
$$;


-- ========== DEALS ==========
drop table if exists raw.hubspot_deals;
create table raw.hubspot_deals (
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

drop table if exists raw._stg_hubspot_deals_csv;
create table raw._stg_hubspot_deals_csv (
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

copy raw._stg_hubspot_deals_csv
from '/workspace/codex1/data/Data Quality - Deals.csv'
with (format csv, header false);

insert into raw.hubspot_deals
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
from raw._stg_hubspot_deals_csv
where coalesce(trim(deal_id), '') <> ''
  and lower(trim(deal_id)) <> 'deal id'
  and lower(trim(deal_id)) not like 'hubspot import%';

drop table if exists raw._stg_hubspot_deals_csv;

-- ========== TICKETS ==========
drop table if exists raw.hubspot_tickets;
create table raw.hubspot_tickets (
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

drop table if exists raw._stg_hubspot_tickets_csv;
create table raw._stg_hubspot_tickets_csv (
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

copy raw._stg_hubspot_tickets_csv
from '/workspace/codex1/data/Data Quality - Tickets.csv'
with (format csv, header false);

insert into raw.hubspot_tickets
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
    raw.normalize_hubspot_id(deal_id) as deal_id,
    nullif(trim(first_payment_date_crm), '') as first_payment_date_crm,
    nullif(trim(payment_status_sales_crm), '') as payment_status_sales_crm,
    nullif(trim(po_number_sales), '') as po_number_sales,
    nullif(trim(ticket_owner), '') as ticket_owner,
    nullif(trim(leader_name), '') as leader_name
from raw._stg_hubspot_tickets_csv
where coalesce(trim(ticket_id), '') <> ''
  and lower(trim(ticket_id)) <> 'ticket id'
  and lower(trim(ticket_id)) not like 'hubspot import%';

drop table if exists raw._stg_hubspot_tickets_csv;
