# MAD System Documentation

## Scope

This document describes the current MAD system based on the artifacts available in this repository:

- product context in `architecture.md`
- database schemas in `schemas/`
- EDA reports in `reports/`
- n8n workflow exports in `reference-data/`

Important limitation: this repository is an EDA toolkit/example workspace, not the production MAD application repository. The data flow below is therefore reconstructed from schema, reports, and workflow exports, not from the full live codebase.

## What MAD Is

MAD stands for MEGA Agent Directory, a web application for searching and discovering real estate agents and teams across the United States. The application exposes:

- agent search
- team search
- location search
- a dashboard showing enrichment and coverage status

At the product level, the client runs in HubSpot CMS, authenticates users through Google OAuth plus a custom `FelloAuth` layer, and calls backend APIs that query agent, team, and brokerage data stores.

## Current System Overview

The available artifacts point to a system with three main data layers:

1. `public.new_unified_agents`
   The primary agent-level table. This is the richest dataset and appears to be the main downstream source for agent-facing search and enrichment metrics.

2. `public."Team_Summary"`
   The team-level table. This appears to aggregate team identity, size, brokerage, customer status, and some enrichment outputs such as website and tech-stack data.

3. `public.mad_dashboard`
   A derived snapshot table storing periodic KPI summaries used by the MAD dashboard rather than row-level entities.

## Inferred End-to-End Data Flow

### 1. Scraping / Source Ingestion

The system appears to ingest data from multiple upstream source families into the core entity tables.

Evidence from `Team_Summary.source` shows these major inputs:

- `Data_Homes`
- `Data_Maps_Teams`
- `Data_KW`
- `Data_Realtor`
- `Data_Remax`
- `Data_BHHS`
- `wsj_real_trends_teams_medium`
- `wsj_real_trends_teams_large`
- `wsj_real_trends_teams_mega`
- `Data_AT_Properties`

These source names strongly suggest a combination of:

- direct source-specific scrapers
- brokerage-specific datasets
- map/profile scraping
- ranked team imports

For the tech-stack enrichment path, the n8n workflow explicitly selects rows from `Team_Summary` where:

- `Website` is present
- `source` includes `Data_Maps_Teams`
- `team_crm_main` is still null

That indicates one scrape/import stage first populates team websites and base metadata, and a later enrichment stage runs only on rows that are still missing tech-stack classification.

### 2. Enrichment

The clearest enrichment workflow present in this repo is the n8n pipeline:

- `Tech Stack Finder Main`
- `Tech Stack Finder - Oxylabs custom parser`

That flow does the following:

1. Query `Team_Summary` from Postgres for teams with websites but missing CRM data.
2. Batch rows through n8n.
3. Call Oxylabs Real-Time API against a BuiltWith URL derived from the team website domain.
4. Parse BuiltWith-style sections such as:
   - `Content Management System`
   - `Agency`
   - `Analytics and Tracking`
5. Use LLM-based extraction and cleanup to identify:
   - CRM tools
   - marketing tools
6. Write normalized results back to Supabase into `Team_Summary.team_crm_main` and `Team_Summary.marketing_tools`.

The workflow also shows a parallel enrichment pattern for `new_unified_agents`:

- update `new_unified_agents.tech_stack`
- update `updated_at`
- use `supabase_uuid` as the key

The schema and reports suggest additional enrichment layers already happened before data reaches the current tables:

- contact normalization: `phone_digits`, `email_clean`
- identity consolidation: `original_uuids`, `full_name`, `source`, `source_1`
- brokerage normalization: `brokerage_name_main`
- CRM/marketing normalization: `crm_main`, `marketing_main`, `CRM_sorted`, `marketing_sorted`
- customer enrichment: `fello_customer_status`, `fello_customer_uuid`, `fello_customer_status_main`
- maps/profile linkage: `maps_id`
- inferred entity typing: `entity`
- AI-derived classification: `agent_designation_ai`
- ICP-style sentiment buckets in `mad_dashboard`

### 3. Storage

Storage appears split across operational entity tables and derived dashboard snapshots.

Operational/serving tables:

- `public.new_unified_agents`
- `public."Team_Summary"`

Derived dashboard table:

- `public.mad_dashboard`

Although the n8n workflow reads from Postgres and writes through the Supabase node, this most likely points to the same underlying Postgres/Supabase data platform rather than separate databases.

### 4. Publishing to MAD Web Applications

The publishing path is only partially visible in this repo, but the app-level architecture is clear:

1. MAD frontend pages in HubSpot CMS load after authentication.
2. The frontend calls a backend API layer labeled `Fello API`.
3. That API hits:
   - natural-language search
   - database access services
4. Database access reads from agent/team/brokerage datasets.
5. MAD dashboard cards likely read from `mad_dashboard`, while search results likely read from `new_unified_agents` and `Team_Summary`.

So the current publication chain is:

`source scraping/imports -> entity enrichment -> Postgres/Supabase tables -> API layer -> HubSpot-hosted MAD web UI`

## Current Database Schema Review

## 1. `public.new_unified_agents`

This is the main agent-level record and includes these field groups.

### Identity and entity linkage

- `supabase_uuid`
- `first_name`, `last_name`, `full_name`
- `original_uuids`
- `entity`
- `source`, `source_1`
- `is_primary_contact`

### Contact and location

- `email`, `email_clean`
- `phone`, `phone_digits`
- `office_number`
- `city`, `state`, `zip_code`, `full_address`

### Profiles and websites

- `profile_link`
- `website`, `website_clean`
- `team_page_url`
- `photo_url`
- `social_links`
- `facebook`, `instagram`, `youtube`, `twitter`, `tiktok`, `linkedin`

### Professional attributes

- `job_title`
- `agent_designation`
- `agent_designation_ai`
- `experience_years`
- `team_id`
- `team_name`
- `team_size_count`
- `team_size`
- `sales_marketing_team`
- `brokerage_name`
- `brokerage_name_main`
- `organization_names`
- `mls_number`

### Performance and marketplace data

- `average_price`, `average_price_main`
- `for_sale_count`, `for_sale_min`, `for_sale_max`
- `sales_last_12_months`
- `total_sales`
- `zillow_id`
- `zillow_address_url`
- `zillow_review`, `zillow_rating`, `zillow_team_status`, `zillow_top_agent`, `zillow_premium`
- `realtor_review`, `realtor_rating`, `realtor_premium`
- `google_rating`, `google_rating_count`

### Tech stack and enrichment

- `tech_stack`
- `CRM`, `crm_main`, `CRM_sorted`
- `marketing_tools`, `marketing_main`, `marketing_sorted`, `marketingTools_combined`
- `rashi_crm`
- `maps_id`

### Customer / internal enrichment

- `review_status`
- `review_comments`
- `fello_customer_status`
- `fello_customer_uuid`
- `fello_customer_status_main`
- `rt_verified_agent_main`
- `is_luxury_agents_kw`
- `shailja_brokerage`

### What is currently well populated

- `full_name` is nearly complete
- `email` coverage is fairly strong
- `phone` coverage is usable but incomplete
- basic agent volume is large enough for production search use

### What is partially populated

- `team_id`
- `brokerage_name`
- `experience_years`
- `state`
- all CRM / marketing / tech-stack related fields
- ratings/reviews across Zillow, Google, Realtor
- team-size normalization

### What is missing but valuable

- per-field provenance and scrape timestamp by source
- freshness timestamp for each enrichment family
- confidence score for AI-derived fields
- normalized brokerage ID rather than only brokerage text
- canonical office ID / office record linkage
- robust location normalization with lat/lng, county, metro, ZIP5
- dedupe cluster ID and survivor/source-of-truth flags
- record-level publishability / quality score
- error reason fields for failed enrichments
- explicit last successful scrape for profile, website, ratings, tech stack

## 2. `public."Team_Summary"`

This is the team-level counterpart with these field groups.

### Team identity and source

- `uuid`
- `team_name`
- `uuid_text`
- `source`
- `entity`
- `⚠️team_id_⚠️(DONT_USE_THIS!!!)`

### Team attributes

- `team_size_count`
- `size`
- `brokerage_old`
- `brokerage`
- `state`, `city`, `zip_code`
- `rank_2025`
- `volume`
- `sides`

### Website and discovery enrichment

- `Website`
- `serper_results`
- `ai_website`
- `reasoning`
- `website_url_logo_dev`

### Tech stack and customer enrichment

- `fello_customer_status`
- `rt_verified_team_main`
- `team_crm_main`
- `marketing_tools`

### What is currently well populated

- `team_name`
- `city`
- `source`
- `size`
- `fello_customer_status`

### What is partially populated

- `state`
- `brokerage`
- `team_size_count`
- `ai_website`
- `rank_2025`
- `sides`
- `team_crm_main`
- `marketing_tools`

### What is missing but valuable

- canonical team ID without the current warning field
- clean team website status and validation timestamp
- normalized brokerage ID
- canonical office / market center linkage
- standardized source metadata and source priority
- tech-stack freshness timestamp and extraction confidence
- lead/account linkage to CRM owner or sales territory
- publication flags for whether a team is eligible to appear in MAD

## 3. `public.mad_dashboard`

This table is a snapshot/KPI table, not a searchable entity store.

### Currently collected fields

- total counts: `total_count`
- enrichment tiers: `tier1_count` to `tier4_count`, percentages
- non-enriched count: `Not_Enriched_yet`
- individual ICP counts: positive, neutral, negative, unclassified
- team counts: `total_teams`, `total_agents_in_teams`
- team-size buckets: `Individual`, `Small`, `Medium`, `Large`, `Mega`, `Market_Center`
- brokerage counters: `KW`, `Remax`, `BHHS`, `exp_Realty`
- `created_at`

### Partially populated / structurally weak fields

- early rows have null brokerage counters
- `icp_unclassified` is typed as `text` while the values behave like counts
- `Individual`, `Small`, `Medium`, `Large`, `Mega`, `Market_Center` are typed as `text` while the values behave like counts
- snapshot semantics are implicit; there is no run ID, source version, or job status

### Missing but valuable

- snapshot job ID / pipeline run ID
- snapshot date key separate from `created_at`
- source-table version or watermark
- build status and error fields
- derived metric definitions/versioning
- counts by source family, geography, brokerage, and freshness bucket

## Current Automations, Scripts, APIs, and Services

## n8n automations present in repo

### `Tech Stack Finder Main`

- Triggered manually or via webhook
- Reads candidate team rows from Postgres
- Batches rows
- Calls the Oxylabs subworkflow per row

### `Tech Stack Finder - Oxylabs custom parser`

- Receives a row from parent workflow
- Calls Oxylabs Real-Time API
- Uses BuiltWith-derived content
- Filters relevant sections
- Uses code nodes plus LLM nodes to classify tools
- Updates `Team_Summary`
- Contains a partially disabled path for `new_unified_agents.tech_stack`

## Python scripts

No Python scripts are present in this repository. That does not mean Python is absent from the real MAD stack, only that this repo does not contain those scripts.

## APIs and third-party services identified

### User-facing / app layer

- HubSpot CMS
- Google OAuth
- Fello API
- natural-language search service

### Data/enrichment layer

- PostgreSQL
- Supabase
- Oxylabs Real-Time API
- BuiltWith-derived parsing flow
- Google Gemini
- xAI Grok
- Serper data stored in `serper_results`
- `logo.dev` for website logo resolution

### Analytics and tracking in product architecture

- Amplitude
- Google Tag Manager
- Facebook Pixel
- Microsoft Clarity
- VWO
- Kiflo
- FirstPromoter
- Snitcher
- Vector

## Points of Fragility, Duplication, and Inefficiency

## Fragility

1. Heavy dependence on website-based enrichment.
   If `Website` is missing, invalid, blocked, or stale, the tech-stack path fails.

2. Multi-step AI extraction pipeline.
   Oxylabs parsing plus LLM extraction plus code cleanup creates several failure points and makes deterministic debugging harder.

3. Mixed typing in `mad_dashboard`.
   Count-like fields stored as `text` are a schema smell and can silently break aggregations or downstream dashboards.

4. Hidden derivation logic.
   The repo shows the output tables and one enrichment workflow, but not the full SQL or orchestration that builds `mad_dashboard`. That makes lineage hard to audit.

5. Source inconsistency and outliers.
   Reports show impossible values such as:
   - team size up to `500000`
   - experience up to `4020`
   - negative or clearly invalid rating/review combinations
   These can distort dashboard metrics and search ranking.

6. Credential exposure in exported workflow JSON.
   The Oxylabs workflow export includes a live-looking Basic auth value. Even if obsolete, storing secrets in exports is an operational risk.

## Duplication

1. Multiple representations of the same concept in `new_unified_agents`.
   Examples:
   - `brokerage_name` and `brokerage_name_main`
   - `CRM`, `crm_main`, `CRM_sorted`
   - `marketing_tools`, `marketing_main`, `marketing_sorted`, `marketingTools_combined`
   - social links both as `social_links` and platform-specific columns

2. Team identity duplication.
   `Team_Summary` includes a warning-labeled team ID field, while `new_unified_agents` uses `team_id`. That suggests weak canonical team identity management.

3. Enrichment written at both team and agent levels.
   Tech-stack data exists in team fields and agent fields, which risks drift unless propagation rules are explicit.

## Inefficiency

1. Batch-by-batch row enrichment through n8n.
   This is easy to operate but inefficient for very large datasets and hard to backfill consistently.

2. Recomputing enrichment for null-only fields without freshness logic.
   The current selection pattern is based on `team_crm_main IS NULL`, not on staleness or source updates.

3. Dashboard snapshots without run metadata.
   Repeated snapshots on the same day are hard to compare or explain because there is no visible job ID, code version, or source watermark.

4. Weak data quality guardrails before publishing.
   The reports show major outliers and null-heavy fields, suggesting limited validation before the data becomes queryable or appears in dashboard counts.

5. Normalization logic spread across schema and workflow code.
   CRM classification is partly in LLM extraction and partly in handwritten JavaScript allowlists. That creates maintenance overhead and inconsistent outcomes.

## Recommended Next Documentation/Engineering Steps

1. Capture the exact SQL or job that populates `mad_dashboard`.
2. Export or document every n8n workflow that writes to `new_unified_agents` or `Team_Summary`.
3. Add a field-level data dictionary with source, type, owner, and freshness.
4. Introduce canonical IDs for agent, team, brokerage, and office entities.
5. Add pipeline metadata tables for job runs, failures, and source watermarks.
6. Separate raw scraped values from normalized/published values.
7. Fix type issues in `mad_dashboard` before further dashboard logic builds on it.
