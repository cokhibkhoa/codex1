/*
Purpose:
- Clean and standardize ticket data from HubSpot raw layer.

Input:
- raw.hubspot_tickets

Output grain:
- 1 row per ticket_id in clean.v_clean_tickets

Business note:
- Required fields and status normalization may vary by pipeline.
- TODO: confirm required field list and status mapping with business owner.
*/

create schema if not exists clean;

create or replace view clean.v_clean_tickets as
with source_data as (
    select
        nullif(trim(ticket_id), '') as ticket_id,
        nullif(trim(ticket_name), '') as ticket_name,
        nullif(trim(payment_status_sales_crm), '') as payment_status_raw,
        nullif(trim(first_name_ticket_owner), '') as owner_name_raw,
        nullif(trim(deal_id), '') as associated_deal_id,
        nullif(trim(fob_price), '')::numeric as fob_price,
        nullif(trim(quantity_xn), '')::numeric as quantity,
        nullif(trim(create_date), '')::timestamp as created_at
    from raw.hubspot_tickets
),
normalized as (
    select
        ticket_id,
        ticket_name,
        lower(payment_status_raw) as payment_status_normalized,
        owner_name_raw as owner_name,
        associated_deal_id,
        fob_price,
        quantity,
        (fob_price * quantity) as ticket_amount,
        created_at
    from source_data
)
select
    ticket_id,
    ticket_name,
    payment_status_normalized,
    owner_name,
    associated_deal_id,
    fob_price,
    quantity,
    ticket_amount,
    created_at
from normalized;
