/*
Purpose:
- Build a unified error log view for downstream reporting/export.

Input:
- checks.v_check_null_required_fields
- checks.v_check_duplicate_ticket_id
- checks.v_check_amount_mismatch

Output grain:
- 1 row per data quality error in marts.v_error_log

Business note:
- Keep schema stable for Google Sheets/dashboard ingestion.
- TODO: align final error_code taxonomy with business team.
*/

create schema if not exists marts;

create or replace view marts.v_error_log as
select
    rule_id,
    ticket_id,
    null::text as associated_deal_id,
    missing_field as error_detail,
    severity,
    detected_at
from checks.v_check_null_required_fields

union all

select
    rule_id,
    ticket_id,
    null::text as associated_deal_id,
    ('duplicate_count=' || row_count::text) as error_detail,
    severity,
    detected_at
from checks.v_check_duplicate_ticket_id

union all

select
    rule_id,
    ticket_id,
    associated_deal_id,
    (
        'ticket_sum=' || coalesce(ticket_amount::text, 'null')
        || ', deal_amount=' || coalesce(deal_amount::text, 'null')
        || ', ticket_count=' || coalesce(ticket_count::text, 'null')
        || ', pct_diff=' || coalesce(round(pct_diff::numeric, 4)::text, 'null')
    ) as error_detail,
    severity,
    detected_at
from checks.v_check_amount_mismatch;
