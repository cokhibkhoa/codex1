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
        cast(ticket_id as text) as ticket_id,
        nullif(trim(subject), '') as subject,
        nullif(trim(status), '') as status_raw,
        nullif(trim(priority), '') as priority_raw,
        nullif(trim(owner_email), '') as owner_email_raw,
        nullif(trim(associated_deal_id), '') as associated_deal_id,
        nullif(trim(amount), '')::numeric as amount_raw,
        created_at,
        updated_at
    from raw.hubspot_tickets
),
normalized as (
    select
        ticket_id,
        subject,
        lower(status_raw) as status_normalized,
        lower(priority_raw) as priority_normalized,
        lower(owner_email_raw) as owner_email_normalized,
        associated_deal_id,
        amount_raw as amount,
        created_at,
        updated_at
    from source_data
)
select
    ticket_id,
    subject,
    status_normalized,
    priority_normalized,
    owner_email_normalized,
    associated_deal_id,
    amount,
    created_at,
    updated_at
from normalized;
