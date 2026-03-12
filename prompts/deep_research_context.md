# Deep Research Context Prompt (for Codex sessions)

## Project
Internal CRM Data Quality for SME using PostgreSQL, output to Google Sheets/dashboard.

## Data sources
- HubSpot export/API sync
- Main entities: deals, tickets

## Known issues
- Missing required data
- Invalid format
- Business logic mismatch
- Wrong mapping
- Duplicates
- Multi-value anomalies
- Amount mismatch

## Constraints
- Implementation-first, practical, minimal, maintainable
- Avoid over-engineering
- Do not assume business rule without evidence
- Mark unresolved rules as TODO

## Expected outputs from Codex
1. SQL draft in layers: raw -> clean -> checks -> marts
2. Rule list with severity and owner
3. Error log view for downstream dashboard/Sheets
4. Weekly summary for quality trend monitoring

## Notes for assistant
- Prefer clear SQL over clever SQL.
- Keep naming consistent and explicit.
- Add short business notes in SQL headers.
