# MEGA Agent Directory Example

This directory contains analysis artifacts for the MEGA Agent Directory (MAD) domain. It combines system documentation, captured schemas, exploratory SQL, generated reports, and workflow reference data used to understand the current MAD data platform.

The most important material in this example lives under `docs/`, which explains the current MAD architecture, enrichment workflows, serving tables, and audit findings.

## Start Here

If you are new to this example, read the files in this order:

1. `docs/CURRENT_SYSTEM_AUDIT.md`
   Repo-based audit of the current data flow, schema coverage, fragility, duplication, and inefficiencies.
2. `docs/MAD_SYSTEM_DOCUMENTATION.md`
   Consolidated system narrative covering ingestion, enrichment, storage, publishing, and current table design.
3. `docs/architecture.md`
   Product and application overview for the MAD frontend, auth, API, and data access layers.
4. `docs/mad_tables_overview.md`
   High-level explanation of the main database tables used by MAD.
5. `docs/team-size-webhook.md`, `docs/crm-agent.md`, `docs/social-media-agent.md`
   Workflow-specific documentation for the main enrichment stages.
6. `reports/`
   Generated EDA summaries for important tables.
7. `schemas/`
   Captured DDL for the underlying tables.
8. `reference-data/`
   Workflow exports and supporting JSON used to reconstruct behavior.

## What Each Area Contains

`docs/`

- current-system documentation for MAD
- product architecture notes
- workflow-level documentation for team-size, CRM, and social enrichment
- table overview and current-state audit

`schemas/`

- captured table DDL for source, intermediate, and serving tables
- useful for checking exact column names, types, constraints, and indexes

`queries/`

- exploratory SQL used during the analysis
- focused on null rates, distributions, categorical coverage, and data quality checks

`reports/`

- generated markdown summaries of the SQL analysis
- useful for quickly reviewing field coverage, outliers, and major findings

`reference-data/`

- exported n8n workflow JSON and other supporting reference files
- useful for reconstructing enrichment behavior where live systems are not available

## Important Limitations

This is not the production MAD application repository. It does not include:

- the live backend application code
- the live database
- the full n8n workspace
- the source code for every external service referenced by the workflows

As a result, some conclusions in the docs are reconstructed from captured artifacts rather than verified against the running system.

## Why This Example Exists

The goal of this folder is to make the MAD example understandable without needing the live system. It provides enough documentation and analysis context for another engineer to review the current pipeline, inspect the schemas, and identify the main operational and data-model issues before planning changes.
