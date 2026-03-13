# PostgreSQL EDA Agent Toolkit Guide

Use this repository as a context pack for an AI agent that performs repeatable exploratory data analysis on PostgreSQL schemas.

## Files To Provide To The Agent

| File | Purpose | Typical Role |
|------|---------|--------------|
| `AGENT_SYSTEM_PROMPT.md` | Operating rules, workflow expectations, output contract | `system` |
| `EDA_PLAYBOOK.md` | Analysis phases, scenario generation rules, severity rules | supporting context |
| `SCHEMA_CAPTURE_TEMPLATE.md` | Required schema capture format and finding template | supporting context |
| `EDA_SQL_TEMPLATES.md` | Reusable SQL patterns by scenario category | supporting context |

## Recommended Run Flow

1. Set PostgreSQL connection environment variables.
2. Load `AGENT_SYSTEM_PROMPT.md` as the base system prompt.
3. Append the other three docs as additional context.
4. Start the agent with a user instruction such as:

```text
Perform a full EDA on the PostgreSQL database connected via environment variables.
Target schema: public
Start with Phase 1 and continue through Phase 4.
Write all generated files under ./eda_output/
```

5. Review the generated output:

```text
eda_output/
├── ddl_docs/
├── eda_queries/
└── eda_report/
```

## Repository Conventions

- `docs/` is the toolkit source of truth.
- `examples/` contains sample artifacts from prior analysis work.
- Generated analysis output should not be committed at the repository root.

## Customization

| Change | Where |
|--------|-------|
| Add a new check | `EDA_PLAYBOOK.md` and `EDA_SQL_TEMPLATES.md` |
| Change schema capture format | `SCHEMA_CAPTURE_TEMPLATE.md` |
| Change severity rules | `EDA_PLAYBOOK.md` |
| Provide domain-specific examples | `examples/` |
