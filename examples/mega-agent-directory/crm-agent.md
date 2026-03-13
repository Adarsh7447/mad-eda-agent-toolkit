# CRM Agent

## Purpose

The CRM agent is the MAD workflow step that detects CRM and marketing-tool signals from a team website and writes those results back into the database.

In the current artifacts, this is represented by the n8n workflows:

- `Tech Stack Finder Main`
- `Tech Stack Finder - Oxylabs custom parser`

Despite the name "CRM agent", this workflow is really a tech-stack enrichment step. It tries to identify:

- CRM tools
- marketing tools
- related website technology signals useful for downstream classification

## Where It Is Used in the MAD Flow

Based on the documented MAD sequence, this is the second step:

1. Team Size, Website Finder & Brokerage
2. CRM Agent
3. Social Media Agent

This means the CRM agent depends on the first step having already produced or confirmed a usable website.

The workflow confirms that assumption directly because it only processes rows where:

- `Website` is not null
- `Website` is not empty
- `Website` is not `not found`
- `source` includes `Data_Maps_Teams`
- `team_crm_main` is null

So this step is run after website discovery, and before social enrichment.

## What the Workflow Actually Does

The CRM agent has a parent workflow and a sub-workflow.

### Parent workflow: `Tech Stack Finder Main`

The parent workflow:

1. Starts from either:
   - a manual trigger
   - a webhook trigger
2. Runs a Postgres query against `public."Team_Summary"`.
3. Selects candidate team rows that have websites but no CRM enrichment yet.
4. Splits the rows into batches.
5. Waits between batches.
6. Calls the sub-workflow once per row.

### Sub-workflow: `Tech Stack Finder - Oxylabs custom parser`

The sub-workflow:

1. Receives a `Team_Summary` row from the parent workflow.
2. Calls Oxylabs Real-Time API.
3. Queries a BuiltWith-style page derived from the row’s `Website` domain.
4. Parses headings from the response.
5. Keeps only:
   - `Content Management System`
   - `Agency`
   - `Analytics and Tracking`
6. Deduplicates and restructures the extracted text.
7. Uses LLM-assisted extraction and normalization.
8. Separates CRM-related tools from non-CRM marketing tools.
9. Updates the database with the results.

## Input Expected

This workflow does not expose a clean external API contract like the team-size webhook. Its effective input is a `Team_Summary` row selected from the database.

### Required row-level input

The row must have:

- `uuid`
- `Website`

And it is selected only when:

- `team_crm_main IS NULL`
- `source` matches the workflow selection logic

### Important fields used by the workflow

- `uuid`
  Used to update the correct `Team_Summary` row.

- `Website`
  Used to derive the domain and generate the BuiltWith/Oxylabs lookup URL.

- `rashi_crm`
  Present in the workflow as an auxiliary field path for further tool extraction.

## Output Expected

The main persisted outputs are written back into `public."Team_Summary"`.

### Database fields updated

- `team_crm_main`
- `marketing_tools`

### Success path

On success, the workflow writes normalized arrays of:

- CRM tools
- marketing tools

### Failure path

If the website lookup or extraction fails, the workflow writes fallback values like:

- `Not found on BuiltWith`

into the CRM and marketing-tool target fields.

## Database Write Behavior

The clearest active writes in the workflow are:

### `Team_Summary`

The workflow updates `public."Team_Summary"` using:

- `uuid` as the key
- `team_crm_main` as the CRM output field
- `marketing_tools` as the marketing-tool output field

### `new_unified_agents`

There is also a disabled path that appears intended to update:

- `new_unified_agents.tech_stack`
- `updated_at`

That suggests the broader design may eventually propagate tech-stack enrichment to agent-level rows too, but the artifact in this repo shows the active path focused on `Team_Summary`.

## How It Fits Into the Whole MAD System

At a system level, this workflow sits between website discovery and later downstream enrichment.

The likely chain is:

1. raw source data lands in source tables
2. team-size / website step identifies or confirms team website context
3. CRM agent enriches the website into tech-stack signals
4. database stores CRM and marketing-tool data
5. social media agent uses team/site identity context for social discovery
6. unified tables and dashboards consume the enriched fields

So the CRM agent is not the first discovery step. It is a secondary enrichment layer that depends on prior website resolution.

## What This Step Adds to MAD

This step improves the system by adding:

- CRM visibility at the team/site level
- marketing-tool visibility
- better segmentation for sales and ICP analysis
- technology signals for downstream dashboards and filtering

It also helps explain why MAD schemas contain fields like:

- `team_crm_main`
- `marketing_tools`
- `CRM`
- `crm_main`
- `marketing_main`
- `tech_stack`

## Operational Characteristics

### Trigger style

- manual trigger available
- webhook trigger available
- batch-oriented processing

### External services used

- Postgres
- Supabase
- Oxylabs
- BuiltWith-derived parser flow
- Google Gemini
- xAI Grok

### Why the batching exists

The parent workflow uses batch splitting plus wait steps, which suggests the workflow is trying to:

- avoid rate limits
- reduce pressure on external services
- control throughput

## Limitations and Caveats

## 1. Website-dependent

If the earlier workflow does not produce a valid `Website`, this step cannot run meaningfully.

## 2. LLM-assisted normalization

The workflow depends on LLM extraction plus custom JavaScript logic, so the final classification is not purely deterministic.

## 3. Cross-table lineage is incomplete in this repo

The workflow clearly updates `Team_Summary`, but the full propagation into agent-level fields is not fully represented here.

## 4. Security issue in the artifact

The exported workflow contains live-looking credentials/API values. Those should not remain in committed workflow artifacts.

## Practical Summary

If you want one-line positioning:

`crm-agent` is the MAD tech-stack enrichment workflow that takes a known team website, detects CRM and marketing tools through Oxylabs plus LLM parsing, and writes the results back to team-level database records.
