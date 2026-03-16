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
        nullif(trim(ticket_id), '') as ticket_id_raw,
        nullif(trim(ticket_name), '') as ticket_name,
        nullif(trim(payment_status_sales_crm), '') as payment_status_raw,
        nullif(trim(ticket_owner), '') as owner_name_raw,
        nullif(trim(deal_id), '') as deal_id_raw,
        nullif(trim(fob_price), '')::numeric as fob_price,
        nullif(trim(quantity_xn), '')::numeric as quantity,
        nullif(trim(create_date), '')::timestamp::date as created_date
    from raw.hubspot_tickets
), normalized_ids as (
    select
        case
            when ticket_id_raw ~ '^[+-]?\\d+(\\.\\d+)?([eE][+-]?\\d+)?$'
                then regexp_replace((ticket_id_raw::numeric)::text, '\\.0+$', '')
            else ticket_id_raw
        end as ticket_id,
        ticket_name,
        lower(payment_status_raw) as payment_status_normalized,
        owner_name_raw as owner_name,
        case
            when deal_id_raw ~ '^[+-]?\\d+(\\.\\d+)?([eE][+-]?\\d+)?$'
                then regexp_replace((deal_id_raw::numeric)::text, '\\.0+$', '')
            else deal_id_raw
        end as associated_deal_id_normalized,
        array_remove(regexp_split_to_array(coalesce(deal_id_raw, ''), '\\s*[,;|/]\\s*'), '') as deal_id_parts,
        fob_price,
        quantity,
        created_date
    from source_data
), filtered_single_deal as (
    select
        ticket_id,
        ticket_name,
        payment_status_normalized,
        owner_name,
        associated_deal_id_normalized as associated_deal_id,
        fob_price,
        quantity,
        (fob_price * quantity) as ticket_amount,
        created_date
    from normalized_ids
    where cardinality(deal_id_parts) <= 1
), deduplicated as (
    select
        *,
        row_number() over (
            partition by ticket_id
            order by created_date desc nulls last, associated_deal_id nulls last, ticket_name
        ) as rn
    from filtered_single_deal
    where ticket_id is not null
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
    created_date
from deduplicated
where rn = 1;
