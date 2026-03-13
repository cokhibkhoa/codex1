/*
Purpose:
- Load HubSpot deals/tickets CSV exports into raw schema for downstream DQ checks.

Input files:
- data/Data Quality - Deals.csv
- data/Data Quality - Tickets.csv

Notes:
- HubSpot export includes 2 metadata lines before the CSV header.
- COPY uses `tail -n +3` to skip these lines.
*/

create schema if not exists raw;

drop table if exists raw.hubspot_deals;
create table raw.hubspot_deals (
    deal_id text,
    deal_name text,
    po_number_sales text,
    country_sales text,
    customer_code_sales text,
    first_payment_date_crm text,
    payment_status_sales_crm text,
    total_number_of_items_sales text,
    sales_confirmation_value_sales text,
    ticket_id text,
    deal_owner_first_name text,
    first_name text
);

copy raw.hubspot_deals
from program 'tail -n +3 data/Data Quality - Deals.csv'
with (format csv, header true);

drop table if exists raw.hubspot_tickets;
create table raw.hubspot_tickets (
    ticket_id text,
    ticket_name text,
    create_date text,
    type_of_products text,
    customer_code_xn text,
    fob_price text,
    quantity_xn text,
    style_xn text,
    color_xn text,
    deal_id text,
    first_payment_date_crm text,
    payment_status_sales_crm text,
    po_number_sales text,
    ticket_owner text,
    leader_name text
);

copy raw.hubspot_tickets
from program 'tail -n +3 data/Data Quality - Tickets.csv'
with (format csv, header true);
