/*
Purpose:
- Detect duplicate deal_id records from raw ingestion.

Input:
- raw.hubspot_deals

Output grain:
- 1 row per duplicate deal_id in checks.v_check_duplicate_deal_id

Business note:
- If source allows versioned records, this rule should be adjusted.
- TODO: confirm whether duplicate deal_id can be legitimate for your sync mode.
*/

create schema if not exists checks;

create or replace view checks.v_check_duplicate_deal_id as
with duplicate_key as (
    select
        nullif(trim(deal_id), '') as deal_id,
        count(*) as row_count
    from raw.hubspot_deals
    group by nullif(trim(deal_id), '')
    having count(*) > 1
)
select
    'RQ_DEAL_001'::text as rule_id,
    d.deal_id,
    d.row_count,
    'HIGH'::text as severity,
    now() as detected_at
from duplicate_key d
where d.deal_id is not null;
