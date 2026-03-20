/*
Purpose:
- Build clean deals layer for downstream checks and marts.

Input:
- raw.hubspot_deals

Business rule:
- Clean phase keeps only deals with first_payment_date >= 2025-01-01.
*/

create schema if not exists clean;

create or replace view clean.v_clean_deals as
select
    nullif(trim(deal_id), '') as deal_id,
    nullif(trim(deal_name), '') as deal_name,
    nullif(trim(po_number_sales), '') as po_number,
    nullif(trim(country_sales), '') as country_sales,
    nullif(trim(customer_code_sales), '') as customer_code,
    nullif(trim(first_payment_date_crm), '')::date as first_payment_date,
    lower(nullif(trim(payment_status_sales_crm), '')) as payment_status_normalized,
    nullif(trim(total_number_of_items_sales), '')::numeric as total_number_of_items,
    nullif(trim(shipping_estimate_sales), '')::numeric as shipping_estimate,
    nullif(trim(handling_fee), '')::numeric as handling_fee,
    nullif(trim(sales_confirmation_value_sales), '')::numeric as gross_sale_value,
    (
        coalesce(nullif(trim(sales_confirmation_value_sales), '')::numeric, 0)
        - coalesce(nullif(trim(shipping_estimate_sales), '')::numeric, 0)
        - coalesce(nullif(trim(handling_fee), '')::numeric, 0)
    ) as net_sale_value,
    raw.normalize_hubspot_id(ticket_id) as ticket_id,
    nullif(trim(deal_owner_first_name), '') as owner_name,
    nullif(trim(leader_name), '') as team_leader
from raw.hubspot_deals
where nullif(trim(deal_id), '') is not null
  and nullif(trim(first_payment_date_crm), '')::date >= date '2025-01-01';
