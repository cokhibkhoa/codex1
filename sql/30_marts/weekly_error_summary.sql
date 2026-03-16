/*
Purpose:
- Summarize data quality errors by month, entity, and rule for dashboard trend monitoring.

Input:
- marts.v_error_log

Output grain:
- 1 row per month_start_date per entity_type per rule_id in marts.v_monthly_error_summary

Business note:
- Month boundary uses PostgreSQL date_trunc('month').
- TODO: confirm timezone and reporting calendar definition.
*/

create schema if not exists marts;

create or replace view marts.v_monthly_error_summary as
select
    date_trunc('month', detected_at)::date as month_start_date,
    entity_type,
    rule_id,
    severity,
    count(*) as error_count,
    count(distinct entity_id) as affected_entities
from marts.v_error_log
group by
    date_trunc('month', detected_at)::date,
    entity_type,
    rule_id,
    severity
order by
    month_start_date desc,
    entity_type,
    error_count desc;
