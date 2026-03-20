/*
Purpose:
- Detect amount mismatch between ticket totals and associated deal values.

Input:
- clean.v_clean_tickets
- clean.v_clean_deals

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
        deal_id,
        net_sale_value as deal_amount,
        owner_name,
        team_leader,
        payment_status_normalized
    from clean.v_clean_deals
    where payment_status_normalized in ('complete payment', 'deposit only')
),
ticket_amount as (
    select
        associated_deal_id as deal_id,
        count(*) as ticket_count,
        sum(ticket_amount) as total_ticket_amount,
        min(owner_name) as owner_name,
        min(team_leader) as team_leader
    from clean.v_clean_tickets
    where associated_deal_id is not null
      and payment_status_normalized in ('deposit 50%', 'pay 100%')
    group by associated_deal_id
),
joined as (
    select
        t.deal_id,
        t.ticket_count,
        t.total_ticket_amount,
        d.deal_amount,
        coalesce(d.owner_name, t.owner_name) as owner_name,
        coalesce(d.team_leader, t.team_leader) as team_leader,
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
    owner_name,
    team_leader,
    pct_diff,
    ticket_count,
    'MEDIUM'::text as severity,
    now() as detected_at
from joined
where deal_amount is not null
  and total_ticket_amount is not null
  and pct_diff > 0.20;  -- TODO: confirm threshold (20% default)
