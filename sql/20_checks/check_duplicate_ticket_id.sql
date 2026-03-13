/*
Purpose:
- Detect duplicate ticket_id records from raw ingestion.

Input:
- raw.hubspot_tickets

Output grain:
- 1 row per duplicate ticket_id in checks.v_check_duplicate_ticket_id

Business note:
- If source allows versioned records, this rule should be adjusted.
- TODO: confirm whether duplicate ticket_id can be legitimate for your sync mode.
*/

create schema if not exists checks;

create or replace view checks.v_check_duplicate_ticket_id as
with duplicate_key as (
    select
        nullif(trim(ticket_id), '') as ticket_id,
        count(*) as row_count
    from raw.hubspot_tickets
    group by nullif(trim(ticket_id), '')
    having count(*) > 1
)
select
    'RQ_TICKET_002'::text as rule_id,
    d.ticket_id,
    d.row_count,
    'HIGH'::text as severity,
    now() as detected_at
from duplicate_key d
where d.ticket_id is not null;
