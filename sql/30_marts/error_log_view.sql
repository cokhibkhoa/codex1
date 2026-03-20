/*
Purpose:
- Build marts for downstream Google Sheets assignment and reporting/export.

Input:
- checks.v_check_null_required_fields
- checks.v_check_duplicate_ticket_id
- checks.v_check_null_required_deal_fields
- checks.v_check_duplicate_deal_id
- checks.v_check_amount_mismatch

Output grain:
- marts.v_error_log: 1 row per data quality error
- marts.v_error_assignment_queue: action-oriented detail rows for sales follow-up
- marts.v_error_report_summary: aggregated rows for dashboard/reporting
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
    d.owner_name,
    d.team_leader,
    e.missing_field as error_detail,
    e.severity,
    e.detected_at
from checks.v_check_null_required_deal_fields e
left join clean.v_clean_deals d
    on d.deal_id = e.deal_id

union all

select
    'deal'::text as entity_type,
    e.deal_id as entity_id,
    e.rule_id,
    null::text as ticket_id,
    e.deal_id,
    e.deal_id as associated_deal_id,
    d.owner_name,
    d.team_leader,
    ('duplicate_count=' || e.row_count::text) as error_detail,
    e.severity,
    e.detected_at
from checks.v_check_duplicate_deal_id e
left join clean.v_clean_deals d
    on d.deal_id = e.deal_id

union all

select
    'deal'::text as entity_type,
    e.associated_deal_id as entity_id,
    e.rule_id,
    e.ticket_id,
    e.associated_deal_id as deal_id,
    e.associated_deal_id,
    e.owner_name,
    e.team_leader,
    (
        'ticket_amount=' || coalesce(e.ticket_amount::text, 'null')
        || '; deal_amount=' || coalesce(e.deal_amount::text, 'null')
        || '; pct_diff=' || coalesce(round(e.pct_diff::numeric, 4)::text, 'null')
    ) as error_detail,
    e.severity,
    e.detected_at
from checks.v_check_amount_mismatch e;

create or replace view marts.v_error_assignment_queue as
select
    entity_type,
    entity_id,
    ticket_id,
    deal_id,
    associated_deal_id,
    owner_name,
    team_leader,
    rule_id,
    error_detail,
    case
        when rule_id in ('RQ_TICKET_001', 'RQ_DEAL_002') then
            'Điền giá trị còn thiếu tại field được nêu trong error_detail rồi xuất lại dữ liệu cho Google Sheets.'
        when rule_id in ('RQ_TICKET_002', 'RQ_DEAL_001') then
            'Rà soát bản ghi trùng ID trong nguồn và giữ lại duy nhất bản ghi đúng.'
        when rule_id = 'RQ_DEAL_099' then
            'So sánh lại net sale value của deal với tổng ticket amount và sửa payment status/value/fee nếu sai.'
        else
            'Kiểm tra nguồn dữ liệu, sửa bản ghi liên quan và đồng bộ lại báo cáo downstream.'
    end as suggested_fix,
    severity,
    detected_at
from marts.v_error_log;

create or replace view marts.v_error_report_summary as
select
    entity_type,
    rule_id,
    severity,
    owner_name,
    team_leader,
    count(*) as error_count,
    count(distinct entity_id) as affected_entities,
    min(detected_at) as first_detected_at,
    max(detected_at) as last_detected_at
from marts.v_error_log
group by
    entity_type,
    rule_id,
    severity,
    owner_name,
    team_leader;
