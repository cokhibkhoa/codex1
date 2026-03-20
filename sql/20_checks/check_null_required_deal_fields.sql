/*
Purpose:
- Detect deals missing required fields.

Input:
- clean.v_clean_deals

Output grain:
- 1 row per missing field per deal_id in checks.v_check_null_required_deal_fields

Business note:
- Required fields below are starter defaults only.
- TODO: confirm mandatory fields by pipeline/stage.
*/

create schema if not exists checks;

create or replace view checks.v_check_null_required_deal_fields as
select
    'RQ_DEAL_002'::text as rule_id,
    d.deal_id,
    missing_field,
    'HIGH'::text as severity,
    now() as detected_at
from clean.v_clean_deals d
cross join lateral (
    values
        ('deal_name', d.deal_name),
        ('payment_status_normalized', d.payment_status_normalized),
        ('gross_sale_value', d.gross_sale_value::text),
        ('owner_name', d.owner_name),
        ('team_leader', d.team_leader)
) as field_check(missing_field, field_value)
where d.deal_id is not null
  and field_value is null;
