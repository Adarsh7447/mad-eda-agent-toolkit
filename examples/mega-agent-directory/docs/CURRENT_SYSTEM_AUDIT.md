# MAD Current System Audit

## Summary

This document reconstructs the current MAD system from the artifacts available in this repository. It is a repo-based audit, not a live production validation. The repo contains schema captures, EDA reports, n8n workflow exports, and system notes, but it does not contain the production application code, live database, or the source code of external enrichment services.

The clearest current-state pattern is:

`source scrape/import -> team/website enrichment -> CRM/tech-stack enrichment -> social enrichment -> serving tables in Postgres/Supabase -> API layer -> HubSpot-hosted UI`

Three tables appear to anchor the published experience:

- `public.new_unified_agents`: primary agent-serving table
- `public."Team_Summary"`: team-level serving and enrichment table
- `public.mad_dashboard`: derived KPI snapshot table

## Evidence Model

This audit uses two evidence labels:

- `Confirmed`: directly supported by a schema file, workflow export, report, or markdown artifact in this repo
- `Inferred`: highly likely from the artifact set, but not directly provable because the live implementation is missing from the repo

## Current Pipeline

### 1. Source ingestion

Status: `Confirmed`

The current system pulls data from multiple source families into source-specific tables and then promotes parts of that data into serving tables.

Confirmed source families include:

- `Data_Homes`
- `Data_Maps_Teams`
- `Data_KW`
- `Data_Realtor`
- `Data_Remax`
- `Data_BHHS`
- `Data_AT_Properties`
- `wsj_real_trends_teams_small`
- `wsj_real_trends_teams_medium`
- `wsj_real_trends_teams_large`
- `wsj_real_trends_teams_mega`
- Real Trends agent batches such as `agents`, `agents_2`, `agens_3`, `agents_4`
- Zillow-enriched individual batches such as `only_agents_1` through `only_agents_6`

What is visible:

- source-specific raw or semi-processed tables exist in the schema captures
- `new_unified_agents.source` and `Team_Summary.source` preserve source lineage text
- the data modification report shows SQL that constructs `Team_Summary_1`, backfills `team_id`, inserts reviewed unified-agent records, and deletes low-quality source rows

What is inferred:

- some of these sources are scraped directly while others are imported in batches
- raw ingestion, cleanup, and promotion are mixed together rather than split into explicit raw and canonical layers

### 2. Team and website enrichment

Status: `Confirmed` for service contract, `Inferred` for exact caller flow

The first major enrichment step is the team-size webhook service described in `team-size-webhook.md`. It is a separate service, not a direct database writer.

Confirmed service behavior:

- receives per-agent or per-team context through `POST /api/v1/enrich` or `/api/v1/enrich/async`
- uses `list_*` request fields such as name, email, phone, brokerage, team name, website, and location
- searches for a likely website with Serper when no website is provided
- uses Grok to select the best site and likely team page
- scrapes the homepage and team page with Oxylabs
- extracts team size, team members, brokerage, team name, designation, and detected CRMs
- returns structured results with status, confidence, reasoning, and error fields

Confirmed outputs returned by the service:

- `team_size_count`
- `team_size_category`
- `team_members`
- `team_page_url`
- `homepage_url`
- `team_name`
- `brokerage_name`
- `agent_designation`
- `detected_crms`
- `confidence`
- `reasoning`

What is inferred:

- an orchestrator, likely n8n, persists those outputs into `new_unified_agents`, `Team_Summary`, or both
- this step establishes the website and team context required by downstream enrichment

### 3. CRM and tech-stack enrichment

Status: `Confirmed`

The clearest in-repo automation is the n8n pair:

- `Tech Stack Finder Main`
- `Tech Stack Finder - Oxylabs custom parser`

Confirmed workflow behavior:

- parent workflow is manually or webhook triggered
- it queries `public."Team_Summary"` for rows with a website and missing CRM enrichment
- it batches rows and calls the sub-workflow once per row
- the sub-workflow derives a BuiltWith-style target from `Website`
- it calls Oxylabs Real-Time API
- it filters headings such as CMS, agency, analytics/tracking
- it uses code nodes plus LLM nodes to extract CRM and marketing tools
- it updates `Team_Summary.team_crm_main` and `Team_Summary.marketing_tools`

Confirmed workflow selection pattern:

- `Website` must be present
- `source` includes `Data_Maps_Teams`
- `team_crm_main` is null

Confirmed fragility in this stage:

- this path is website-dependent
- classification is partly LLM-driven and partly code-driven
- failures write fallback values such as `Not found on BuiltWith`

What is inferred:

- there was intent to propagate tech-stack data to `new_unified_agents.tech_stack`, but the active artifact is team-table-centric
- the null-only selection pattern is acting as workflow state management

### 4. Social enrichment

Status: `Confirmed` from markdown description, `Partially confirmed` for workflow export

The social media agent is documented as a webhook-driven n8n automation that writes directly to `new_unified_agents`.

Confirmed documented behavior:

- accepts a webhook payload containing at least `uuid`
- fetches the row from `public.new_unified_agents`
- builds a search query from team, person, brokerage, and location context
- calls Serper
- uses Grok to choose likely social profiles
- flattens the structured result into column updates

Confirmed target fields:

- `facebook`
- `instagram`
- `tiktok`
- `linkedin`
- `youtube`
- `twitter`
- `social_label`
- `social_Score`
- `updated_at`

Evidence gap:

- the markdown references `social-media-2.json`, but that export is not present in this repo

### 5. Storage and serving

Status: `Confirmed`

The current storage model mixes source history, normalization, enrichment results, and app-facing values in the same public tables.

Serving layer tables used by the MAD product:

- `new_unified_agents`
- `Team_Summary`
- `mad_dashboard`

Supporting and upstream tables visible in the repo:

- source family tables such as `Data_*`
- Real Trends team ranking tables
- duplicate-review and duplicate-confidence tables
- mapping tables such as `Team_Summary_1` and `Team_Summary_2`
- customer status tables

What is inferred:

- there is no hard separation between raw, normalized, canonical, and published data
- enrichment jobs write directly into user-facing tables

### 6. Publishing to the web application

Status: `Confirmed` at architecture level, `Inferred` at query-path level

The application overview and system documentation support this path:

- HubSpot CMS hosts the front end
- Google OAuth plus `FelloAuth` handles authentication
- the UI calls `Fello API`
- the backend reads agent, team, and brokerage data
- PostgREST is referenced as the direct API path for MAD UI table access

Likely publication path:

`serving tables -> database API / PostgREST / Fello API -> HubSpot MAD UI`

What is missing from the repo:

- live backend code
- API query definitions
- exact jobs that build `mad_dashboard`

## Current Schema Review

### `public.new_unified_agents`

This is the primary agent-level table and the richest published dataset.

#### Currently collected fields

Identity and linkage:

- `supabase_uuid`
- `first_name`, `last_name`, `full_name`
- `original_uuids`
- `source`, `source_1`
- `entity`
- `team_id`
- `maps_id`
- `is_primary_contact`

Contact and location:

- `email`, `email_clean`
- `phone`, `phone_digits`
- `office_number`
- `city`, `state`, `zip_code`, `full_address`

Profile and digital presence:

- `profile_link`
- `website`, `website_clean`
- `team_page_url`
- `photo_url`
- `about`
- `social_links`
- platform columns for Facebook, Instagram, YouTube, Twitter, TikTok, LinkedIn

Professional and team attributes:

- `job_title`
- `agent_designation`
- `agent_designation_ai`
- `experience_years`
- `team_name`
- `team_size_count`
- `team_size`
- `sales_marketing_team`
- `brokerage_name`
- `brokerage_name_main`
- `organization_names`
- `mls_number`

Performance and ratings:

- `average_price`, `average_price_main`
- `for_sale_count`, `for_sale_min`, `for_sale_max`
- `sales_last_12_months`
- `total_sales`
- `zillow_id`
- `zillow_address_url`
- `zillow_review`, `zillow_rating`, `zillow_team_status`, `zillow_top_agent`, `zillow_premium`
- `realtor_review`, `realtor_rating`, `realtor_premium`
- `google_rating`, `google_rating_count`

Tech stack and internal enrichment:

- `tech_stack`
- `CRM`, `crm_main`, `CRM_sorted`
- `marketing_tools`, `marketing_main`, `marketing_sorted`, `marketingTools_combined`
- `rashi_crm`
- `review_status`, `review_comments`
- `fello_customer_status`, `fello_customer_uuid`, `fello_customer_status_main`
- `rt_verified_agent_main`
- `is_luxury_agents_kw`
- `shailja_brokerage`

#### Well-populated fields

Supported by the EDA report:

- `full_name`: nearly complete
- `email`: strong relative coverage
- `phone`: usable but incomplete
- `team_name` and source lineage: present often enough to support published search use

#### Partially populated fields

Supported by the EDA report:

- `state`: about 30.92% missing
- `team_id`: about 45.63% missing
- `brokerage_name`: about 50.77% missing
- `experience_years`: about 50.87% missing
- `CRM`: about 88.13% missing

Operationally partial even when non-null:

- team-size fields contain outliers and sentinel-like values
- review/rating fields are uneven across Zillow, Google, and Realtor
- normalized arrays often coexist with raw text variants, which weakens trust in the single source of truth

#### Missing but valuable fields

- field-level provenance by source
- last successful scrape timestamp per enrichment family
- freshness and staleness indicators
- confidence score for AI-derived fields
- canonical brokerage ID rather than only text/array variants
- canonical office ID / market center linkage
- dedupe cluster ID and survivor reason
- publishability / record quality score
- enrichment failure reason and retry state
- lat/lng, county, metro, ZIP5 normalization

### `public."Team_Summary"`

This is the team-level table and also the clearest landing area for website and CRM enrichment.

#### Currently collected fields

Identity and source:

- `uuid`
- `team_name`
- `uuid_text`
- `source`
- `entity`
- `⚠️team_id_⚠️(DONT_USE_THIS!!!)`

Team attributes:

- `team_size_count`
- `size`
- `brokerage_old`
- `brokerage`
- `state`, `city`, `zip_code`
- `rank_2025`
- `volume`
- `sides`

Website and discovery enrichment:

- `Website`
- `serper_results`
- `ai_website`
- `reasoning`
- `website_url_logo_dev`

Customer and tech-stack enrichment:

- `fello_customer_status`
- `rt_verified_team_main`
- `team_crm_main`
- `marketing_tools`

#### Well-populated fields

Supported by the EDA report:

- `team_name`
- `city`
- `source`
- `size`
- `fello_customer_status`

#### Partially populated fields

Supported by the EDA report:

- `state`: about 31.83% missing
- `team_size_count`: about 1.03% missing, but quality is uneven because of right-skew and large outliers
- `brokerage`: about 23,173 rows missing
- `ai_website`: about 50,532 rows missing
- `rank_2025`: about 95.97% missing
- `sides`: about 95.38% missing

Operationally partial:

- `team_crm_main` and `marketing_tools` depend on website-driven enrichment and are not universal
- `Website` and `ai_website` suggest competing website-resolution paths
- the warning-labeled team ID field indicates unresolved canonical identity design

#### Missing but valuable fields

- canonical team ID suitable for downstream use
- website validation status and last checked timestamp
- normalized brokerage ID
- office / market-center linkage
- source priority / survivorship metadata
- tech-stack freshness timestamp and confidence
- team-level publishability / quality flags
- enrichment job status, retry count, and failure reason

### `public.mad_dashboard`

This table is a derived snapshot table, not a canonical entity store.

#### Currently collected fields

- `total_count`
- `tier1_count` to `tier4_count`
- tier percentages
- `Not_Enriched_yet`
- `individual_icp_positive`, `individual_icp_neutral`, `individual_icp_negative`
- `icp_unclassified`
- `total_teams`
- `total_agents_in_teams`
- `Individual`, `Small`, `Medium`, `Large`, `Mega`, `Market_Center`
- `KW`, `Remax`, `BHHS`, `exp_Realty`
- `created_at`

#### Partially populated or structurally weak fields

- brokerage counters are null in earlier rows
- `icp_unclassified` is typed as `text` but behaves like a count
- `Individual`, `Small`, `Medium`, `Large`, `Mega`, `Market_Center` are typed as `text` but behave like counts
- there is no visible run ID, snapshot key, source watermark, or job status

#### Missing but valuable fields

- pipeline run ID
- snapshot date key separate from `created_at`
- source-table watermark/version
- build status and error metadata
- metric definition versioning
- freshness breakdowns by source, geography, and enrichment tier

## Automations, Scripts, APIs, and Services

### n8n automations confirmed in repo

- `Tech Stack Finder Main`
- `Tech Stack Finder - Oxylabs custom parser`
- `clone2_main_workflow.json`
- `clone2_sub_workflow.json`

The `clone2_*` workflow pair shows an additional agent-enrichment path centered on Zillow discovery and scraping, using Perplexity, ScraperAPI, Gemini, Claude, OpenAI, Supabase, and Google Sheets to enrich agent records in `agents_2`.

### Python scripts

No Python scripts are present in this repository.

Implication:

- Python may still exist in the real MAD stack
- this repo cannot validate or document those scripts directly

### External APIs and third-party services identified

App and access layer:

- HubSpot CMS
- Google OAuth
- `FelloAuth`
- Fello API
- PostgREST
- natural-language search service

Enrichment and data platform:

- PostgreSQL
- Supabase
- Oxylabs Real-Time API
- BuiltWith-derived lookup flow
- Serper
- `logo.dev`
- Google Gemini
- xAI Grok
- Perplexity
- ScraperAPI
- OpenAI
- Anthropic Claude

Background service dependencies documented for the team-size service:

- FastAPI
- Celery
- Redis

## Points of Fragility

1. Direct mutation of serving tables by enrichment workflows.
   `Team_Summary` and `new_unified_agents` are both serving tables and workflow write targets. That couples partially successful enrichment with production-facing data.

2. Website dependency across multiple enrichment stages.
   Missing or bad website resolution blocks CRM extraction and weakens social discovery quality.

3. LLM-assisted extraction in critical enrichment paths.
   CRM classification, team-size reasoning, and social profile selection rely on model prompts plus code transforms, which makes debugging and deterministic replay difficult.

4. Workflow state encoded as field nullability.
   Patterns like `team_crm_main IS NULL` are serving as job-state logic. That prevents explicit freshness, retries, and stale-data reruns.

5. Weak lineage from source rows to published values.
   `original_uuids` preserves some ancestry, but field-level provenance, transform version, and run metadata are missing.

6. Outlier-prone published metrics.
   The EDA reports show extreme values such as team sizes up to `500000` in `new_unified_agents`, team sizes up to `16000` in `Team_Summary`, and rapidly changing dashboard distributions. These can distort dashboards and ranking.

7. Hidden dashboard build logic.
   The repo captures the schema and output of `mad_dashboard`, but not the job that computes it. Reproducing or debugging a bad dashboard snapshot is therefore difficult.

8. Credential exposure in workflow artifacts.
   Several markdown summaries note live-looking API keys or auth values embedded in exported workflows. Even if stale, this is an operational risk.

## Duplication And Inconsistency

1. Multiple representations of the same concept in `new_unified_agents`.
   Examples include:

- `brokerage_name` vs `brokerage_name_main`
- `CRM` vs `crm_main` vs `CRM_sorted`
- `marketing_tools` vs `marketing_main` vs `marketing_sorted` vs `marketingTools_combined`
- `social_links` JSON vs platform-specific columns
- `team_size` vs `team_size_main`

2. Team identity appears unresolved.
   `Team_Summary` has a warning-labeled team ID column, while `new_unified_agents` relies on `team_id`. The data modification report also shows source-specific backfills to populate team IDs.

3. Website discovery has overlapping outputs.
   `Website`, `ai_website`, `team_page_url`, `website_clean`, and service-returned `homepage_url` indicate multiple competing website fields with unclear precedence.

4. Raw, normalized, and published values are mixed in the same tables.
   Source text, cleaned arrays, reviewed statuses, and final serving fields coexist without a clear canonical boundary.

## Inefficiencies

1. Batch-by-batch n8n enrichment over large tables.
   This is easy to operate manually but weak for consistent backfills, throughput, and retry control at MAD scale.

2. Post-ingestion SQL cleanup is doing core data-model work.
   The data modification report shows brokerage normalization, team identity generation, backfills, dedupe promotion, and source cleanup happening after ingestion rather than through a clearly staged pipeline.

3. Null-based rerun logic ignores freshness.
   Rows with stale but non-null enrichment values are not naturally selected for recomputation.

4. Dashboard snapshots are hard to compare.
   `mad_dashboard` contains multiple same-day snapshots with changing column populations and no run metadata.

5. Duplicate review and cleanup are semi-manual.
   The unified-agent promotion flow relies on review tables and verdict-driven inserts/deletes, which suggests significant operational overhead.

## Known Unknowns

These items require live-system access or additional repos:

- the production n8n workspace and all workflows that write to `new_unified_agents` or `Team_Summary`
- the actual source code of the team-size webhook service
- any Python scripts used in ingestion, normalization, or publishing
- the SQL or orchestration job that builds `mad_dashboard`
- live API query paths, cache layers, and backend service code
- the missing `social-media-2.json` workflow export

## Practical Conclusions

The current MAD system appears to work by continuously enriching and cleaning production-facing tables rather than promoting data through explicit raw, normalized, canonical, and serving layers. That approach has enabled rapid iteration, but it also creates schema duplication, weak lineage, workflow fragility, and operational difficulty when enrichments fail or need replay.

The most important current-state issues are:

- production tables are used as workflow state
- enrichment success depends heavily on website resolution
- key classifications are not fully deterministic
- schema duplication obscures the source of truth
- dashboard lineage is not auditable from the current repo
