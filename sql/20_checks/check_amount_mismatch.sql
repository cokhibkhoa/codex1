/*
Purpose:
- Detect amount mismatch between tickets and associated deals.

Input:
- clean.v_clean_tickets
- raw.hubspot_deals

Output grain:
- 1 row per ticket-deal pair with mismatch in checks.v_check_amount_mismatch

Business note:
- This is a starter rule using percentage difference threshold.
- TODO: confirm join key and mismatch threshold with business owner.
*/

create schema if not exists checks;

create or replace view checks.v_check_amount_mismatch as
with deal_amount as (
    select
        cast(deal_id as text) as deal_id,
        nullif(trim(amount), '')::numeric as deal_amount
    from raw.hubspot_deals
),
joined as (
    select
        t.ticket_id,
        t.associated_deal_id,
        t.amount as ticket_amount,
        d.deal_amount,
        case
            when d.deal_amount is null or d.deal_amount = 0 then null
            else abs(t.amount - d.deal_amount) / d.deal_amount
        end as pct_diff
    from clean.v_clean_tickets t
    left join deal_amount d
        on t.associated_deal_id = d.deal_id
)
select
    'RQ_DEAL_001'::text as rule_id,
    ticket_id,
    associated_deal_id,
    ticket_amount,
    deal_amount,
    pct_diff,
    'MEDIUM'::text as severity,
    now() as detected_at
from joined
where deal_amount is not null
  and ticket_amount is not null
  and pct_diff > 0.20;  -- TODO: confirm threshold (20% default)
