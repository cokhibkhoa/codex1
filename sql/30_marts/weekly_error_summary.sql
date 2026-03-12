/*
Purpose:
- Summarize data quality errors by week and rule for trend monitoring.

Input:
- marts.v_error_log

Output grain:
- 1 row per week_start_date per rule_id in marts.v_weekly_error_summary

Business note:
- Week boundary uses PostgreSQL date_trunc('week').
- TODO: confirm timezone and reporting week definition.
*/

create schema if not exists marts;

create or replace view marts.v_weekly_error_summary as
select
    date_trunc('week', detected_at)::date as week_start_date,
    rule_id,
    severity,
    count(*) as error_count,
    count(distinct ticket_id) as affected_tickets
from marts.v_error_log
group by
    date_trunc('week', detected_at)::date,
    rule_id,
    severity
order by
    week_start_date desc,
    error_count desc;
