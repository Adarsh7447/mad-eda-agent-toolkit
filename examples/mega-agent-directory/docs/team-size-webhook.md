# Team Size Webhook

## Purpose

The `team-size-webhook-main` repository is an enrichment service used in the MAD pipeline to determine:

- team size
- team size category
- team members
- likely team page and homepage
- brokerage name
- team name
- detected CRMs
- agent designation within the team

Its job is to take a raw or lightly normalized agent/team record and return structured enrichment data that can later be written into MAD tables such as `new_unified_agents` or team summary tables by the calling workflow.

Important distinction: this service does not appear to write directly to the MAD database. It is an API that returns enrichment results. The caller, typically n8n or another orchestrator, is responsible for persisting the output.

## Where It Is Used in the MAD Flow

Based on [`flow.md`](/Users/adarshbadjate/code/EDA/flow.md) and the repo itself, this is the first major enrichment step in the current execution sequence:

1. `Team Size, Website Finder & Brokerage`
2. `CRM Agent`
3. `Social Media Agent`

That means this service is used after raw source data has landed, but before CRM and social-media enrichment runs.

In practice, it is the step that establishes the core website/team context needed by later workflows.

## Why This Step Matters

This service is foundational because later enrichment depends on it.

It produces or improves:

- `team_size_count`
- `team_size_category`
- `team_page_url`
- `homepage_url`
- `team_name`
- `brokerage_name`
- `agent_designation`
- `detected_crms`

Those outputs are important for:

- building or validating team identity
- classifying agents as individual/small/medium/large/mega
- locating the website that later workflows use
- powering downstream CRM and social enrichment
- improving agent/team quality in MAD search and dashboard views

## What the Service Actually Does

The main endpoint is:

- `POST /api/v1/enrich`

There is also an async mode:

- `POST /api/v1/enrich/async`

The implemented request lifecycle is:

1. Accept agent input from the caller.
2. If `list_website` is provided, try scraping that site directly first.
3. If direct scraping is not available or fails, search for the likely website using Serper.
4. Use Grok to assess which website is the best candidate.
5. Scrape the homepage with Oxylabs.
6. Extract internal links and identify the most likely team page.
7. Scrape that team page if found.
8. Convert page HTML to markdown/text.
9. Use Grok to estimate team size and extract team members.
10. Extract team name and brokerage name from the scraped content.
11. Detect CRM technologies from the site content.
12. Return a structured response to the caller.

## Input Expected

The live API expects the `list_*` request shape, not the older `full_name` / `email[]` style shown in some older README examples.

### Request fields

- `agent_id`
  Optional in code. If not provided, the service auto-generates one.

- `list_name`
  Agent full name.

- `list_email`
  Agent email as a single string.

- `list_phone`
  Agent phone as a single string.

- `list_team_name`
  Team or organization name.

- `list_brokerage`
  Brokerage name.

- `list_website`
  Known website URL. If present, the service tries this first before searching.

- `list_location`
  City/state or address string.

### Minimum useful input

The service works best when at least one of these is present:

- `list_name`
- `list_team_name`
- `list_brokerage`
- `list_email`
- `list_website`

The strongest requests include:

- name
- team or brokerage
- location
- website if already known

### Example request

```json
{
  "agent_id": "test-agent-123",
  "list_name": "John Smith",
  "list_email": "john@smithrealty.com",
  "list_phone": "+1-555-123-4567",
  "list_team_name": "Smith Realty Group",
  "list_brokerage": "Keller Williams",
  "list_website": "https://smithrealty.com",
  "list_location": "Austin, TX"
}
```

## Output Expected

The synchronous endpoint returns a structured enrichment response.

### Main response fields

- `status`
  One of `success`, `partial`, or `failed`

- `agent_id`
  The request identifier

- `team_size_count`
  Integer result
  Semantics:
  - `> 0` = valid team size
  - `0` = unknown / partial result
  - `-2` = failure response

- `team_size_category`
  One of:
  - `Unknown`
  - `Individual`
  - `Small`
  - `Medium`
  - `Large`
  - `Mega`

- `team_members`
  List of extracted members with:
  - `name`
  - `email`
  - `phone`
  - `designation`

- `team_page_url`
  Team page chosen for analysis if found

- `homepage_url`
  Homepage used for enrichment

- `team_name`
  Extracted team name

- `brokerage_name`
  Extracted brokerage name

- `agent_designation`
  Role(s) inferred for the target agent

- `detected_crms`
  CRM tools found on the website

- `confidence`
  `LOW`, `MEDIUM`, or `HIGH`

- `reasoning`
  Explanation of how the team size result was determined

- `processing_time_ms`
  Total response time

- `error_code`, `error_message`
  Present for failed or partial outcomes

### Example response

```json
{
  "status": "success",
  "agent_id": "test-agent-123",
  "team_size_count": 5,
  "team_size_category": "Small",
  "team_members": [
    {
      "name": "John Smith",
      "email": "john@smithrealty.com",
      "phone": "+1-555-123-4567",
      "designation": "Team Lead"
    }
  ],
  "team_page_url": "https://smithrealty.com/team",
  "homepage_url": "https://smithrealty.com",
  "team_name": "Smith Realty Group",
  "brokerage_name": "Keller Williams",
  "agent_designation": ["Team Lead"],
  "detected_crms": ["Follow Up Boss"],
  "confidence": "HIGH",
  "reasoning": "Found 5 team members listed on the site",
  "processing_time_ms": 4500,
  "error_code": null,
  "error_message": null
}
```

## How It Fits Into the Whole MAD System

At the system level, the likely flow is:

1. Raw source-specific records are scraped or imported into staging/source tables.
2. A workflow calls the team-size webhook with per-agent or per-team context.
3. The webhook searches or scrapes the website and returns structured team enrichment.
4. The caller writes the returned fields back into database tables.
5. Later workflows use those outputs:
   - CRM enrichment uses website/team context
   - social-media enrichment uses homepage/team identity/location context
6. Unified agent and team tables are then used by MAD APIs and dashboards.

So this service is not the entire scraper pipeline by itself. It is an enrichment microservice inside the broader MAD orchestration layer.

## Internal Dependencies

This service relies on:

- Serper
  For search results when a website is not already known

- Oxylabs
  For scraping page HTML

- Grok
  For selecting the best website, selecting the best team page, analyzing team size, and extracting names/designations

- Redis
  For rate limiting and async task support

- Celery
  For async/high-throughput processing

- FastAPI
  For the API interface used by n8n or other callers

## Sync vs Async Usage

### Sync mode

- Endpoint: `POST /api/v1/enrich`
- Best for n8n steps that need the result immediately
- Typical use in MAD: row-by-row enrichment where the workflow writes the result right after the response returns

### Async mode

- Endpoint: `POST /api/v1/enrich/async`
- Best for high-volume backfills or large queues
- Returns a `task_id` instead of the enrichment result immediately

## Key Limitation

This service enriches and returns data, but it does not define the database persistence layer.

That means the full real-world step is:

`source row -> call team-size-webhook -> receive enrichment result -> n8n / orchestrator updates database`

If you need complete lineage for MAD, the next thing to document is the caller workflow that maps this response into database columns.

## Practical Summary

If you want one-line positioning:

`team-size-webhook` is the MAD enrichment API that turns a raw agent/team identity record into structured website, team-size, brokerage, and CRM signals that later workflows can store and build on.
