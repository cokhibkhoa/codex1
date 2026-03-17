/*
Purpose:
- Build ticket pipeline layers:
  CLEAN_BASE -> CLEAN_MULTI_DEAL -> CLEAN_SINGLE_DEAL -> ASSERT_QUALITY.

Input:
- raw.hubspot_tickets

Prerequisite:
- STG tables must be imported manually from local disk before RAW/CLEAN flow execution.

Main grain / PK logic for final table:
- (ticket_id, deal_id)
*/

create schema if not exists clean;
create schema if not exists audit;

-- 1) CLEAN_BASE
create or replace view clean.v_ticket_clean_base as
with prepared as (
    select
        nullif(trim(ticket_id), '') as ticket_id,
        nullif(trim(ticket_name), '') as ticket_name,
        nullif(trim(create_date), '')::timestamp::date as created_date,
        nullif(trim(type_of_products), '') as type_of_products,
        nullif(trim(customer_code_xn), '') as customer_code,
        nullif(trim(fob_price), '')::numeric as fob_price,
        nullif(trim(quantity_xn), '')::numeric as quantity,
        nullif(trim(style_xn), '') as style,
        nullif(trim(color_xn), '') as color,
        nullif(trim(deal_id), '') as deal_id_raw,
        nullif(trim(first_payment_date_crm), '')::date as first_payment_date,
        lower(nullif(trim(payment_status_sales_crm), '')) as payment_status,
        nullif(trim(po_number_sales), '') as po_number,
        nullif(trim(ticket_owner), '') as ticket_owner,
        nullif(trim(leader_name), '') as leader_name
    from raw.hubspot_tickets
), exploded_deals as (
    select
        p.ticket_id,
        p.ticket_name,
        p.created_date,
        p.type_of_products,
        p.customer_code,
        p.fob_price,
        p.quantity,
        (p.fob_price * p.quantity) as ticket_amount,
        p.style,
        p.color,
        raw.normalize_hubspot_id(nullif(trim(piece), '')) as deal_id,
        p.first_payment_date,
        p.payment_status,
        p.po_number,
        p.ticket_owner,
        p.leader_name
    from prepared p
    cross join lateral regexp_split_to_table(coalesce(p.deal_id_raw, ''), '\s*[,;|/]\s*') as piece
)
select
    ticket_id,
    ticket_name,
    created_date,
    type_of_products,
    customer_code,
    fob_price,
    quantity,
    ticket_amount,
    style,
    color,
    deal_id,
    first_payment_date,
    payment_status,
    po_number,
    ticket_owner,
    leader_name
from exploded_deals
where ticket_id is not null
  and deal_id is not null
  and first_payment_date >= date '2025-01-01'
  and payment_status in ('complete', 'deposit');

-- 2) CLEAN_MULTI_DEAL
create or replace view clean.v_ticket_clean_multi_deal as
with base as (
    select * from clean.v_ticket_clean_base
), multi_ticket as (
    select ticket_id
    from base
    group by ticket_id
    having count(distinct deal_id) > 1
)
select b.*
from base b
inner join multi_ticket m using (ticket_id);

-- 3) CLEAN_SINGLE_DEAL (main dataset with grain ticket_id + deal_id)
create or replace view clean.v_ticket_clean_single_deal as
with base as (
    select * from clean.v_ticket_clean_base
), multi_ticket as (
    select distinct ticket_id
    from clean.v_ticket_clean_multi_deal
)
select b.*
from base b
left join multi_ticket m using (ticket_id)
where m.ticket_id is null;

-- Backward compatibility for existing consumers.
create or replace view clean.v_clean_tickets as
select *
from clean.v_ticket_clean_single_deal;

-- 4) ASSERT_QUALITY
create or replace view audit.v_ticket_assert_quality as
with single_deal as (
    select *
    from clean.v_ticket_clean_single_deal
), raw_scoped as (
    select
        nullif(trim(ticket_id), '') as ticket_id,
        raw.normalize_hubspot_id(nullif(trim(deal_id), '')) as deal_id,
        nullif(trim(first_payment_date_crm), '')::date as first_payment_date,
        lower(nullif(trim(payment_status_sales_crm), '')) as payment_status
    from raw.hubspot_tickets
), scoped_raw_after_filter as (
    select *
    from raw_scoped
    where ticket_id is not null
      and deal_id is not null
      and first_payment_date >= date '2025-01-01'
      and payment_status in ('complete', 'deposit')
)
select
    'duplicate_pk' as check_name,
    count(*)::bigint as issue_count
from (
    select ticket_id, deal_id
    from single_deal
    group by ticket_id, deal_id
    having count(*) > 1
) t
union all
select
    'null_key' as check_name,
    count(*)::bigint as issue_count
from single_deal
where ticket_id is null or deal_id is null
union all
select
    'invalid_date_or_status' as check_name,
    count(*)::bigint as issue_count
from single_deal
where first_payment_date < date '2025-01-01'
   or payment_status not in ('complete', 'deposit')
union all
select
    'raw_vs_single_deal_row_gap' as check_name,
    (
        (select count(*) from scoped_raw_after_filter)
        - (select count(*) from single_deal)
    )::bigint as issue_count;
