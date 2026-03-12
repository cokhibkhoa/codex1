/*
Purpose:
- Detect tickets missing required fields.

Input:
- clean.v_clean_tickets

Output grain:
- 1 row per missing field per ticket_id in checks.v_check_null_required_fields

Business note:
- Required fields below are starter defaults only.
- TODO: confirm mandatory fields by pipeline/stage.
*/

create schema if not exists checks;

create or replace view checks.v_check_null_required_fields as
select
    'RQ_TICKET_001'::text as rule_id,
    t.ticket_id,
    missing_field,
    'HIGH'::text as severity,
    now() as detected_at
from clean.v_clean_tickets t
cross join lateral (
    values
        ('subject', t.subject),
        ('status_normalized', t.status_normalized),
        ('owner_email_normalized', t.owner_email_normalized)
) as field_check(missing_field, field_value)
where field_value is null;
