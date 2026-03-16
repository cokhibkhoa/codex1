/*
Purpose:
- Build a unified error log view for downstream reporting/export.

Input:
- checks.v_check_null_required_fields
- checks.v_check_duplicate_ticket_id
- checks.v_check_null_required_deal_fields
- checks.v_check_duplicate_deal_id

Output grain:
- 1 row per data quality error in marts.v_error_log

Business note:
- Keep schema stable for Google Sheets/dashboard ingestion.
- Amount reconciliation is intentionally excluded from this MVP.
*/

create schema if not exists marts;

create or replace view marts.v_error_log as
select
    'ticket'::text as entity_type,
    ticket_id as entity_id,
    rule_id,
    ticket_id,
    null::text as deal_id,
    missing_field as error_detail,
    severity,
    detected_at
from checks.v_check_null_required_fields

union all

select
    'ticket'::text as entity_type,
    ticket_id as entity_id,
    rule_id,
    ticket_id,
    null::text as deal_id,
    ('duplicate_count=' || row_count::text) as error_detail,
    severity,
    detected_at
from checks.v_check_duplicate_ticket_id

union all

select
    'deal'::text as entity_type,
    deal_id as entity_id,
    rule_id,
    null::text as ticket_id,
    deal_id,
    missing_field as error_detail,
    severity,
    detected_at
from checks.v_check_null_required_deal_fields

union all

select
    'deal'::text as entity_type,
    deal_id as entity_id,
    rule_id,
    null::text as ticket_id,
    deal_id,
    ('duplicate_count=' || row_count::text) as error_detail,
    severity,
    detected_at
from checks.v_check_duplicate_deal_id;
