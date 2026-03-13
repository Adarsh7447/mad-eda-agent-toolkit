# Schema Capture Template

Use this template for every table discovered during Phase 1.

File path:

```text
ddl_docs/{table_name}_schema.md
```

## Required Template

```markdown
# Schema: {schema_name}.{table_name}

## Table Metadata
| Field | Value |
|-------|-------|
| Schema | {schema_name} |
| Table | {table_name} |
| Row Count | {row_count} |

## Columns
| Column | Data Type | Nullable | Default | Distinct Count | Null Count | Null % |
|--------|-----------|----------|---------|----------------|------------|--------|
| ... | ... | ... | ... | ... | ... | ... |

## Primary Keys
| Column | Ordinal Position |
|--------|------------------|
| ... | ... |

## Foreign Keys
| Column | References Table | References Column |
|--------|------------------|-------------------|
| ... | ... | ... |

## Indexes
| Index Name | Type | Columns | Predicate |
|------------|------|---------|-----------|
| ... | ... | ... | ... |

## Sample Values
| Column | Sample Values |
|--------|---------------|
| ... | value1, value2, value3 |

## Column Notes
- Flag high-null columns.
- Flag constant columns.
- Flag ambiguous text blobs, encoded arrays, or suspicious identifier fields.
```

## Capture Rules

1. Use exact database identifiers.
2. Record row count once per table.
3. For array and JSON columns, note that cardinality and sample values may be approximate.
4. If a table has no foreign keys or indexes, state that explicitly.
5. If statistics cannot be computed, write `UNKNOWN` and explain why.

## Finding Template

Use this structure in `EDA_FINDINGS.md` when a schema-level issue is found:

```markdown
### Finding: {finding_id}
| Field | Value |
|-------|-------|
| Severity | HIGH / MEDIUM / LOW |
| Table | {table_name} |
| Column | {column_name_or_NA} |
| Check | {scenario_or_phase_id} |
| Summary | {short finding summary} |
| Recommendation | {next action} |
```
