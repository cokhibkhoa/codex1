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
    e.ticket_id as entity_id,
    e.rule_id,
    e.ticket_id,
    null::text as deal_id,
    t.associated_deal_id,
    t.owner_name,
    t.team_leader,
    e.missing_field as error_detail,
    e.severity,
    e.detected_at
from checks.v_check_null_required_fields e
left join clean.v_clean_tickets t
    on t.ticket_id = e.ticket_id

union all

select
    'ticket'::text as entity_type,
    e.ticket_id as entity_id,
    e.rule_id,
    e.ticket_id,
    null::text as deal_id,
    null::text as associated_deal_id,
    null::text as owner_name,
    null::text as team_leader,
    ('duplicate_count=' || e.row_count::text) as error_detail,
    e.severity,
    e.detected_at
from checks.v_check_duplicate_ticket_id e

union all

select
    'deal'::text as entity_type,
    e.deal_id as entity_id,
    e.rule_id,
    null::text as ticket_id,
    e.deal_id,
    e.deal_id as associated_deal_id,
    nullif(trim(d.deal_owner_first_name), '') as owner_name,
    nullif(trim(d.leader_name), '') as team_leader,
    e.missing_field as error_detail,
    e.severity,
    e.detected_at
from checks.v_check_null_required_deal_fields e
left join raw.hubspot_deals d
    on d.deal_id = e.deal_id

union all

select
    'deal'::text as entity_type,
    e.deal_id as entity_id,
    e.rule_id,
    null::text as ticket_id,
    e.deal_id,
    e.deal_id as associated_deal_id,
    nullif(trim(d.deal_owner_first_name), '') as owner_name,
    nullif(trim(d.leader_name), '') as team_leader,
    ('duplicate_count=' || e.row_count::text) as error_detail,
    e.severity,
    e.detected_at
from checks.v_check_duplicate_deal_id e
left join raw.hubspot_deals d
    on d.deal_id = e.deal_id;
