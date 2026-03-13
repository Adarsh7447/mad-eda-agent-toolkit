# PostgreSQL EDA Agent Toolkit

Reusable prompts, playbooks, SQL templates, and example artifacts for running structured exploratory data analysis on PostgreSQL databases with an AI coding agent.

## Repository Purpose

This repository is a toolkit repository, not an application repository.

It contains:
- agent-facing instruction documents
- reusable EDA playbooks and SQL templates
- an example dataset workspace under `examples/mega-agent-directory/`

It does not contain:
- a production web app
- deployment infrastructure
- a packaged CLI or Python library

## Repository Structure

```text
.
├── docs/
│   ├── AGENT_GUIDE.md
│   ├── AGENT_SYSTEM_PROMPT.md
│   ├── EDA_PLAYBOOK.md
│   ├── EDA_SQL_TEMPLATES.md
│   └── SCHEMA_CAPTURE_TEMPLATE.md
├── examples/
│   └── mega-agent-directory/
│       ├── architecture.md
│       ├── queries/
│       ├── reference-data/
│       ├── reports/
│       └── schemas/
└── .gitignore
```

## Prerequisites

- PostgreSQL database access
- environment variables for database connectivity
- an agent/runtime that can read files, write files, and execute SQL

Recommended environment variables:

```bash
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=your_db
export PGUSER=your_user
export PGPASSWORD=your_password
```

## Usage

1. Read [`docs/AGENT_GUIDE.md`](/Users/adarshbadjate/code/EDA/docs/AGENT_GUIDE.md).
2. Use [`docs/AGENT_SYSTEM_PROMPT.md`](/Users/adarshbadjate/code/EDA/docs/AGENT_SYSTEM_PROMPT.md) as the base system prompt.
3. Append [`docs/EDA_PLAYBOOK.md`](/Users/adarshbadjate/code/EDA/docs/EDA_PLAYBOOK.md), [`docs/SCHEMA_CAPTURE_TEMPLATE.md`](/Users/adarshbadjate/code/EDA/docs/SCHEMA_CAPTURE_TEMPLATE.md), and [`docs/EDA_SQL_TEMPLATES.md`](/Users/adarshbadjate/code/EDA/docs/EDA_SQL_TEMPLATES.md) as supporting context.
4. Point the agent at a PostgreSQL schema and an output directory such as `./eda_output/`.
5. Review the generated outputs and compare them with the example artifacts under `examples/mega-agent-directory/`.

## Example Artifacts

`examples/mega-agent-directory/` contains sample DDL captures, exploratory SQL, reports, and domain reference files from a real analysis workflow. These files are examples and reference material, not the toolkit source of truth.
