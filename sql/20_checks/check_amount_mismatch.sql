/*
Purpose:
- Detect amount mismatch between ticket totals and associated deal values.

Input:
- clean.v_clean_tickets
- raw.hubspot_deals

Output grain:
- 1 row per deal with mismatch in checks.v_check_amount_mismatch

Business note:
- This is a starter rule using percentage difference threshold.
- TODO: confirm join key and mismatch threshold with business owner.
*/

create schema if not exists checks;

create or replace view checks.v_check_amount_mismatch as
/*
NOTE:
- Advanced amount reconciliation is out-of-scope for current 1-week dashboard MVP.
- Keep this view as optional exploration and exclude from marts aggregates by default.
*/
with deal_amount as (
    select
        nullif(trim(deal_id), '') as deal_id,
        nullif(trim(sales_confirmation_value_sales), '')::numeric as deal_amount
    from raw.hubspot_deals
),
ticket_amount as (
    select
        associated_deal_id as deal_id,
        count(*) as ticket_count,
        sum(ticket_amount) as total_ticket_amount
    from clean.v_clean_tickets
    where associated_deal_id is not null
    group by associated_deal_id
),
joined as (
    select
        t.deal_id,
        t.ticket_count,
        t.total_ticket_amount,
        d.deal_amount,
        case
            when d.deal_amount is null or d.deal_amount = 0 then null
            else abs(t.total_ticket_amount - d.deal_amount) / d.deal_amount
        end as pct_diff
    from ticket_amount t
    left join deal_amount d
        on t.deal_id = d.deal_id
)
select
    'RQ_DEAL_099'::text as rule_id,
    null::text as ticket_id,
    deal_id as associated_deal_id,
    total_ticket_amount as ticket_amount,
    deal_amount,
    pct_diff,
    ticket_count,
    'MEDIUM'::text as severity,
    now() as detected_at
from joined
where deal_amount is not null
  and total_ticket_amount is not null
  and pct_diff > 0.20;  -- TODO: confirm threshold (20% default)
