/*
Purpose:
- Provide 1-row-per-entity error summary for ticket and deal domains.

Input:
- checks.v_check_null_required_fields
- checks.v_check_duplicate_ticket_id
- checks.v_check_null_required_deal_fields
- checks.v_check_duplicate_deal_id
- checks.v_check_amount_mismatch

Output grain:
- marts.v_ticket_error_summary: 1 row per ticket_id with error attributes
- marts.v_deal_error_summary: 1 row per deal_id with error attributes
*/

create schema if not exists marts;

create or replace view marts.v_ticket_error_summary as
with null_err as (
    select
        ticket_id,
        count(*) as null_error_count,
        string_agg(missing_field, ', ' order by missing_field) as missing_fields
    from checks.v_check_null_required_fields
    group by ticket_id
), dup_err as (
    select
        ticket_id,
        row_count as duplicate_row_count
    from checks.v_check_duplicate_ticket_id
)
select
    coalesce(n.ticket_id, d.ticket_id) as ticket_id,
    (n.ticket_id is not null) as has_null_required_field_error,
    coalesce(n.null_error_count, 0) as null_error_count,
    n.missing_fields,
    (d.ticket_id is not null) as has_duplicate_id_error,
    coalesce(d.duplicate_row_count, 0) as duplicate_row_count,
    (coalesce(n.null_error_count, 0) + case when d.ticket_id is not null then 1 else 0 end) as total_error_types
from null_err n
full outer join dup_err d
    on n.ticket_id = d.ticket_id;

create or replace view marts.v_deal_error_summary as
with null_err as (
    select
        deal_id,
        count(*) as null_error_count,
        string_agg(missing_field, ', ' order by missing_field) as missing_fields
    from checks.v_check_null_required_deal_fields
    group by deal_id
), dup_err as (
    select
        deal_id,
        row_count as duplicate_row_count
    from checks.v_check_duplicate_deal_id
), mismatch_err as (
    select
        associated_deal_id as deal_id,
        count(*) as mismatch_error_count
    from checks.v_check_amount_mismatch
    group by associated_deal_id
)
select
    coalesce(n.deal_id, d.deal_id, m.deal_id) as deal_id,
    (n.deal_id is not null) as has_null_required_field_error,
    coalesce(n.null_error_count, 0) as null_error_count,
    n.missing_fields,
    (d.deal_id is not null) as has_duplicate_id_error,
    coalesce(d.duplicate_row_count, 0) as duplicate_row_count,
    (m.deal_id is not null) as has_amount_mismatch_error,
    coalesce(m.mismatch_error_count, 0) as mismatch_error_count,
    (
        coalesce(n.null_error_count, 0)
        + case when d.deal_id is not null then 1 else 0 end
        + case when m.deal_id is not null then 1 else 0 end
    ) as total_error_types
from null_err n
full outer join dup_err d
    on n.deal_id = d.deal_id
full outer join mismatch_err m
    on coalesce(n.deal_id, d.deal_id) = m.deal_id;
