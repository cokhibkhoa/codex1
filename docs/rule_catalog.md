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


