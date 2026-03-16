# Social Media Agent

## Purpose

The social media agent is the MAD workflow step that discovers likely public social profiles for an agent or team and writes those links plus a score back into `new_unified_agents`.

In the repo, this is represented by the n8n workflow:

- `social-media-2.json`

Its purpose is to enrich records with:

- Facebook
- Instagram
- LinkedIn
- YouTube
- TikTok
- X/Twitter
- Zillow
- a social quality score
- a social quality label

## Where It Is Used in the MAD Flow

This is the third step in the documented sequence:

1. Team Size, Website Finder & Brokerage
2. CRM Agent
3. Social Media Agent

That placement makes sense because this workflow performs best when earlier steps have already enriched:

- homepage or team page URL
- identity fields
- team name or brokerage
- location context

## What the Workflow Actually Does

The workflow is a webhook-driven n8n automation.

### Execution flow

1. `Webhook`
   Receives a POST request containing at least the target record UUID and homepage/source context.

2. `Get a row`
   Reads the matching row from `public.new_unified_agents`.

3. `Limit`
   Restricts execution to the one fetched row.

4. `Build query`
   Builds a Google/Serper search query using:
   - `team_name` if available
   - otherwise the cleaned homepage domain
   - otherwise person name and brokerage
   - location fields like city, state, ZIP
   - real-estate-specific keywords
   - social-domain filters

5. `HTTP Request`
   Calls Serper search.

6. `Find social media`
   Uses an LLM prompt to inspect the search results and identify probable social profile URLs.

7. `Structured Output Parser`
   Forces the model output into a fixed JSON structure.

8. `Code in JavaScript`
   Removes empty platforms and reshapes the result.

9. `Edit Fields`
   Maps the output into flat fields expected by the database update step.

10. `Update a row`
   Writes the enrichment back into `public.new_unified_agents`.

## Input Expected

The workflow input arrives through the webhook and then supplements itself by reading the database row.

### Required webhook input

At minimum, the workflow needs:

- `uuid`

It also references:

- `homepage_url`
- `source_url`

through the webhook payload.

### Database fields used from `new_unified_agents`

The workflow reads fields such as:

- `team_name`
- `city`
- `state`
- `zip_code`
- `phone`
- `full_address`
- `first_name`
- `last_name`
- `email`

These fields are used to construct the search query and help the LLM judge whether a found profile likely belongs to the correct agent or team.

## Output Expected

The workflow writes its results directly into `public.new_unified_agents`.

### Fields updated

- `facebook`
- `instagram`
- `tiktok`
- `linkedin`
- `youtube`
- `twitter`
- `social_label`
- `social_Score`
- `updated_at`

### Output structure before database write

The LLM is forced to return:

- `foundSocials.facebook`
- `foundSocials.instagram`
- `foundSocials.linkedin`
- `foundSocials.youtube`
- `foundSocials.tiktok`
- `foundSocials.x`
- `foundSocials.zillow`
- `score`
- `label`

The workflow then flattens those into database fields.

### Scoring logic

The workflow prompt defines a simple score model:

- Facebook: `+2`
- Instagram: `+2`
- LinkedIn: `+2`
- YouTube: `+2`
- TikTok: `+1`
- X/Twitter: `+1`

And labels are assigned as:

- `good` for score `>= 6`
- `medium` for score `>= 3`
- `poor` for score `< 3`

## How It Fits Into the Whole MAD System

This workflow is a downstream enrichment step that improves profile completeness after identity and website context already exist.

The likely end-to-end chain is:

1. raw source ingestion creates or updates agent rows
2. team-size workflow discovers website/team/brokerage context
3. CRM workflow enriches tech-stack information
4. social media workflow enriches social links and scores
5. the enriched `new_unified_agents` row becomes more useful for MAD search, filtering, scoring, and user-facing displays

So the social media agent is not responsible for entity creation. It enhances already-existing unified agent rows.

## Why This Step Matters

This workflow adds value in several ways:

- improves record completeness
- gives a lightweight quality signal via `social_Score`
- provides direct links to public channels
- helps identify stronger brand presence
- gives downstream sales or product users more context on agent/team maturity

## External Services Used

The workflow uses:

- Supabase
  To read and update `new_unified_agents`

- Serper
  To get search results

- xAI Grok
  To interpret search results and extract likely profile URLs

## Limitations and Caveats

## 1. Search-result dependent

The workflow does not scrape the social platforms directly. It depends on search results containing the relevant profiles.

## 2. Heuristic and LLM-based

The workflow intentionally allows loose matching and then relies on the LLM plus prompt rules to pick likely social URLs.

## 3. Possible field-mapping inconsistency

The workflow extracts Zillow URLs too, but the final database update shown in the artifact does not persist a Zillow field. That means part of the extracted output may be discarded.

## 4. Security issue in the artifact

The workflow export contains live-looking API credentials. Those should be removed or redacted from committed files.

## Practical Summary

If you want one-line positioning:

`social-media-agent` is the MAD webhook workflow that searches for likely public social profiles for an existing unified agent record, scores the result, and writes those social signals back into `new_unified_agents`.
