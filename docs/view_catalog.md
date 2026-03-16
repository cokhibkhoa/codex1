The project uses three SQL views only.

view_name	grain	purpose
checks.v_ticket_null_errors	1 row / ticket_id	Detect missing attributes in tickets
checks.v_deal_null_errors	1 row / deal_id	Detect missing attributes in deals
marts.v_null_error_summary	aggregated	Weekly and monthly error metrics
5. Ticket Null Check

View:

checks.v_ticket_null_errors

Grain:

1 row = 1 ticket_id

Dataset filters:

first_payment_date >= '2025-01-01'
payment_status IN ('complete payment','deposit')

Output columns:

ticket_id
created_date
sale_owner
team_leader

null_attribute_count
null_attribute_list
has_null_error

Definitions:

column	meaning
null_attribute_count	number of blank attributes
null_attribute_list	list of attribute names that are blank
has_null_error	1 if record has blank attributes
6. Deal Null Check

View:

checks.v_deal_null_errors

Grain:

1 row = 1 deal_id

Dataset filter:

first_payment_date >= '2025-01-01'

Output columns:

deal_id
created_date
sale_owner
team_leader

null_attribute_count
null_attribute_list
has_null_error

Definitions:

column	meaning
null_attribute_count	number of blank attributes
null_attribute_list	list of attribute names that are blank
has_null_error	1 if record has blank attributes
7. Error Summary

View:

marts.v_null_error_summary

Purpose:

Aggregate null-attribute errors for dashboard monitoring.

Grain:

time_period + object_type

Time periods:

week
month

Dimensions:

object_type
sale_owner
team_leader

Metrics:

records_with_null_error
total_null_attributes

Definitions:

metric	meaning
records_with_null_error	number of records containing at least one blank attribute
total_null_attributes	total number of blank attributes
8. Pipeline Structure
raw_data
   ↓
checks.v_ticket_null_errors
checks.v_deal_null_errors
   ↓
marts.v_null_error_summary

All objects are implemented as SQL views and rebuilt during each batch run.

9. Future Rules (Next Phase)

Planned rules for future versions:
