# Rule Catalog

# CRM Data Quality Rules

## Global Filter (apply before cleaning)

Only process records that satisfy:

| field | condition |
|---|---|
| first_payment_date | >= '2025-01-01' |

This filter must be applied to **both objects**:

- tickets
- deals

Additional ticket filter:

| field | allowed_values |
|---|---|
| payment_status | 'complete payment', 'deposit' |

Records outside these conditions must be excluded from downstream views.

---

# View Catalog

# View Catalog

| view_name | grain | purpose |
|---|---|---|
| checks.v_ticket_errors | 1 row / ticket_id | Detect ticket data quality issues |
| checks.v_deal_errors | 1 row / deal_id | Detect deal data quality issues |
| marts.v_error_summary | aggregated | Weekly and monthly error summary |

---

# Clean Layer Rules

## clean.v_clean_tickets

grain:
