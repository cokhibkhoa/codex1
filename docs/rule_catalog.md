# CRM Data Quality — Rules & Views

This document defines the **data quality rules and SQL views** used to detect missing attributes in HubSpot CRM exports.

The current version focuses only on **detecting empty attributes** for two objects:

- Tickets
- Deals

The output supports a **weekly and monthly error monitoring dashboard**.

---

# 1. Dataset Scope

Only process records that satisfy the following filters.

## Global Filter

| field | condition |
|---|---|
| first_payment_date | >= '2025-01-01' |

Apply to both objects:

- tickets
- deals

## Ticket Filter

| field | allowed_values |
|---|---|
| payment_status | complete payment, deposit |

Records outside these filters must be excluded from validation.

---

# 2. Objects

| object | primary_key |
|---|---|
| tickets | ticket_id |
| deals | deal_id |

---

# 3. Current Rule

The system currently checks only **missing attributes**.

| rule_name | description |
|---|---|
| null_attributes | detect attributes that are NULL or blank |

Blank definition:

```sql
column IS NULL OR TRIM(column::text) = ''

This rule is applied to all attributes of each object.


duplicate IDs

invalid formats

ticket vs deal amount mismatch

business rule validation
