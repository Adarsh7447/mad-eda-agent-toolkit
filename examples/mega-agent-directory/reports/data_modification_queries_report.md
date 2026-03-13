# Data Modification Queries Report

## Scope

This report summarizes the purpose of the data modification SQL captured in [`data_modification_queries.md`](/Users/adarshbadjate/code/EDA/data_modification_queries.md).

The focus is on:

- what each query group is trying to accomplish
- which tables are being modified
- what role the query plays in the MAD data pipeline
- what risks or operational concerns are visible from the query set

## Overall Summary

The query set is primarily doing five kinds of work:

1. normalizing brokerage values in `new_unified_agents`
2. generating shared team identifiers in source tables
3. building team-level summary rows from source-specific datasets
4. inserting reviewed source records into unified agent tables
5. cleaning up bad, duplicate, or unwanted source data

This indicates the system is heavily dependent on post-ingestion SQL cleanup and normalization, not just raw ingestion.

## Query Families

## 1. Brokerage Normalization

### Target table

- `public.new_unified_agents`

### What the queries do

Multiple `UPDATE` statements map messy `brokerage_name` text into standardized `brokerage_name_main` array values.

### Why this matters

- brokerage filtering becomes reliable
- dashboard counts stop splitting across aliases
- downstream search and segmentation work better

### Main normalized brokerages

- Keller Williams
- eXp Realty
- RE/MAX
- Berkshire Hathaway
- Coldwell Banker
- Compass
- CENTURY 21
- @properties
- NextHome

## 2. Performance Indexing

### Target table

- `public.new_unified_agents`

### What the queries do

Create GIN indexes on array-based columns such as:

- `crm_main`
- `team_size_main`
- `brokerage_name_main`
- `marketing_main`

### Why this matters

These are not business-data changes. They support faster reads for search, analytics, and filters on multi-value columns.

## 3. Team Identity Generation

### Target tables

- `public."Data_Remax"`
- `public."Data_KW"`

### What the queries do

Generate shared UUID-based identifiers for team or office groupings before aggregation.

### Why this matters

This is the bridge between raw source rows and canonical team-level entities. Without it, agent-to-team linking and team summary creation would be unstable.

## 4. Team Summary Construction

### Target table

- `public."Team_Summary_1"`

### What the queries do

Insert aggregated team rows from:

- `public."Data_Remax"`
- `public."Data_KW"`

Each insert groups source records into one team-level entity with fields such as:

- `uuid`
- `team_name`
- `team_size_count`
- `brokerage`
- `city`
- `state`
- `source`

### Why this matters

This is a publishing step from raw source tables into team-serving data.

## 5. Unified Agent Ingestion

### Target table

- `public.unified_agents`

### What the queries do

Insert reviewed records from duplicate-review tables into the unified agent model.

### Input tables

- `public.agents_duplicate_confidence_table`
- `public.agents_3_duplicate_confidence_table`

### Why this matters

These queries show that some source data is only promoted into unified tables after a manual or semi-manual duplicate-review process using `"Match Verdict"`.

## 6. Team ID Backfill

### Target table

- `public.new_unified_agents`

### Source tables used for backfill

- `public."Data_AT_Properties"`
- `public."Data_BHHS"`
- `public."Data_KW"`
- `public."Data_Remax"`

### What the queries do

Update `new_unified_agents.team_id` by matching source UUIDs found in `original_uuids`.

### Why this matters

This connects unified agent rows back to team identifiers that were generated in source-specific workflows.

## 7. Source Cleanup and Removal

### Target tables

- `public.unified_agents`
- `public.new_unified_agents`

### What the queries do

Remove or detach records tied to the `agents_3` source by:

- deleting rows
- removing source tags
- removing rows where the source appears in `source` or `source_1`

### Why this matters

This suggests `agents_3` was considered noisy, superseded, or otherwise unsuitable for continued inclusion in the final dataset.

## 8. Duplicate Cleanup

### Target table

- `public.new_unified_agents`

### What the queries do

There are two main deduplication patterns:

1. delete records tied to source IDs whose duplicate-review verdict was not approved
2. rank duplicate clusters and delete all but the best surviving row

### Survivorship logic used

Rows are ranked using signals such as:

- count of `original_uuids`
- completeness across important fields
- most recent `updated_at`
- key identifiers like email, phone, profile link, and Zillow address URL

### Why this matters

This is a direct data-quality control layer and appears to be critical to keeping `new_unified_agents` usable.

## 9. One-Off Table Cleanup

### Target tables

- `public.agents`
- `public.agents_3`
- `public.zillow_scraper_test`

### What the queries do

- delete malformed rows with null `created_at`
- clear a test/staging scrape table

### Why this matters

These are operational cleanup tasks rather than transformation logic.

## Main Observations

## 1. The system relies on SQL-heavy post-processing

The queries show that raw ingestion alone is not enough. Significant manual or semi-manual normalization happens after source data lands in the database.

## 2. Canonical identity is assembled in stages

Team IDs are generated in source tables first, then pushed into summary tables and backfilled into unified agent tables later.

## 3. Duplicate handling is a core part of the pipeline

The presence of review tables, preview-before-delete flows, and ranked survivorship logic suggests deduplication is not incidental. It is central to the data model.

## 4. Source-level trust varies

The explicit cleanup of `agents_3` implies some sources are not treated equally and may be partially rolled back or excluded after ingestion.

## Risks and Concerns

## 1. High-risk destructive operations

Several queries permanently delete rows from core tables:

- `public.unified_agents`
- `public.new_unified_agents`
- source tables and staging tables

Without runbooks or rollback procedures, these operations are operationally risky.

## 2. Mixed operational and modeling concerns

This query set mixes:

- normalization logic
- identity generation
- ingestion
- cleanup
- destructive deduplication
- indexing

That makes change control harder because infrastructure and data logic are bundled together.

## 3. Heavy dependence on `original_uuids`

Many important updates and deletes rely on `original_uuids` matching correctly. If lineage is incomplete or polluted, the cleanup and backfill logic can affect the wrong rows.

## 4. Source-specific logic is embedded in SQL

Queries are tightly coupled to source names like:

- `agents_3`
- `Data_KW`
- `Data_Remax`
- `Data_BHHS`

This is workable, but it does not scale cleanly unless source behavior is documented and versioned.

## Recommended Next Step

The next useful improvement would be to extend this report into a runbook with one row per query group covering:

- query name
- target tables
- fields modified
- whether it is destructive
- expected row scope
- prerequisites
- validation query
- rollback method
