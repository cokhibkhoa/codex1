/*
Purpose:
- Detect deals missing required fields.

Input:
- raw.hubspot_deals

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
from raw.hubspot_deals d
cross join lateral (
    values
        ('deal_name', nullif(trim(d.deal_name), '')),
        ('payment_status_sales_crm', nullif(trim(d.payment_status_sales_crm), '')),
        ('sales_confirmation_value_sales', nullif(trim(d.sales_confirmation_value_sales), ''))
) as field_check(missing_field, field_value)
where nullif(trim(d.deal_id), '') is not null
  and field_value is null;
