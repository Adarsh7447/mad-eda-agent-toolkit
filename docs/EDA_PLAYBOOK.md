# EDA Playbook
> Agent reads this file at the start of every phase to determine what checks to run.
> Each check has an ID, description, SQL pattern reference, and severity default.

---

## Phase 1 — Schema Capture
> Goal: Build complete `ddl_docs/{table_name}_schema.md` for every table.

**Trigger:** Start of agent run
**Input:** Database connection + target schema name
**Output:** One `.md` file per table in `ddl_docs/`

### Checklist
- [ ] P1-01 List all tables in target schema
- [ ] P1-02 For each table: capture columns, types, nullability, defaults
- [ ] P1-03 For each table: capture primary key(s)
- [ ] P1-04 For each table: capture foreign key(s)
- [ ] P1-05 For each table: capture indexes
- [ ] P1-06 For each table: capture row count
- [ ] P1-07 For each table: capture null count per column
- [ ] P1-08 For each table: capture cardinality per column
- [ ] P1-09 For each table: capture top-5 sample values per column
- [ ] P1-10 For each table: flag ambiguous, high-null, constant columns

**Exit Condition:** All tables have a corresponding `ddl_docs/*.md` file.

---

## Phase 2 — EDA Scenario Generation
> Goal: Read all schema files and produce a prioritised list of EDA questions.

**Trigger:** All Phase 1 files complete
**Input:** All `ddl_docs/*.md` files
**Output:** `eda_report/EDA_SCENARIOS.md`

### How to Generate Scenarios

For EVERY table, automatically generate scenarios from these categories:

#### Category A — Null & Empty Value Analysis
| ID Pattern | Question Template |
|------------|-------------------|
| A-{t}-01 | Which columns in `{table}` have NULL values, and what % of rows are affected? |
| A-{t}-02 | Which TEXT/VARCHAR columns contain empty strings `''` (not NULLs)? |
| A-{t}-03 | Which TEXT/VARCHAR columns contain whitespace-only strings? |
| A-{t}-04 | Are there columns that are 100% NULL (dead columns)? |

#### Category B — Data Type & Format Integrity
| ID Pattern | Question Template |
|------------|-------------------|
| B-{t}-01 | Do any VARCHAR columns store values that look like integers or decimals? |
| B-{t}-02 | Do any VARCHAR columns store values that look like dates or timestamps? |
| B-{t}-03 | Do any VARCHAR columns store values that look like booleans (true/false/0/1/yes/no)? |
| B-{t}-04 | Do any INTEGER/NUMERIC columns contain values that are unexpectedly negative? |
| B-{t}-05 | Are there columns typed as TEXT that have very consistent short lengths (likely should be CHAR or ENUM)? |

#### Category C — Uniqueness & Duplicates
| ID Pattern | Question Template |
|------------|-------------------|
| C-{t}-01 | Does the primary key column(s) have any duplicate values? |
| C-{t}-02 | Are there fully duplicate rows (all columns identical)? |
| C-{t}-03 | Are there near-duplicate rows (all columns identical except PK or timestamp)? |
| C-{t}-04 | Which non-PK columns have cardinality = 1 (constant, no variation)? |
| C-{t}-05 | Which columns have cardinality = total row count (potential natural keys)? |

#### Category D — Distribution & Outliers (Numeric Columns)
| ID Pattern | Question Template |
|------------|-------------------|
| D-{t}-01 | What is the min, max, mean, median, stddev for each numeric column? |
| D-{t}-02 | Are there numeric outliers beyond 3 standard deviations from the mean? |
| D-{t}-03 | What is the distribution of values in each low-cardinality categorical column? |
| D-{t}-04 | Are there numeric columns where values are suspiciously round (all multiples of 10/100)? |

#### Category E — Date & Timestamp Checks
| ID Pattern | Question Template |
|------------|-------------------|
| E-{t}-01 | What is the min and max date/timestamp in each date column? |
| E-{t}-02 | Are there date values in the future (beyond today)? |
| E-{t}-03 | Are there date values unrealistically far in the past (e.g., before 1900)? |
| E-{t}-04 | Are there gaps in time-series data (missing days/months if expected to be continuous)? |
| E-{t}-05 | Is `created_at` always <= `updated_at` where both columns exist? |

#### Category F — Referential Integrity (Cross-Table)
| ID Pattern | Question Template |
|------------|-------------------|
| F-{t1}{t2}-01 | Are there FK values in `{table1}.{fk_col}` that do not exist in `{table2}.{pk_col}`? |
| F-{t1}{t2}-02 | Are there orphaned records in `{table1}` after a left join to `{table2}`? |
| F-{t1}{t2}-03 | What is the join cardinality between `{table1}` and `{table2}` (1:1, 1:N, N:M)? |

#### Category G — String Quality
| ID Pattern | Question Template |
|------------|-------------------|
| G-{t}-01 | Are there leading or trailing whitespace values in any TEXT column? |
| G-{t}-02 | Are there mixed case inconsistencies (e.g., 'USA', 'usa', 'Usa') in low-cardinality text columns? |
| G-{t}-03 | Are there special characters or control characters in text columns? |
| G-{t}-04 | Do email columns (if any) contain values that fail a basic email format check? |
| G-{t}-05 | Do phone/zip/ID columns have inconsistent length or format? |

---

### EDA_SCENARIOS.md Format

```markdown
# EDA Scenarios

Generated: {timestamp}
Tables in scope: {list}

---

## {table_name}

| Scenario ID | Category | Question | Priority | Status |
|-------------|----------|----------|----------|--------|
| A-orders-01 | Nulls     | Which columns have NULLs and at what %? | HIGH | PENDING |
| B-orders-02 | Type Check | Do any VARCHAR columns look like dates? | MEDIUM | PENDING |
...

---
```

**Priority Assignment Rules:**
- HIGH: Any Category C (duplicates on PK), Category F (FK violations), A-xx-04 (100% null columns)
- MEDIUM: All other Category A, B, D, E checks
- LOW: Category G (string quality), D-xx-04 (round numbers)

---

## Phase 3 — EDA Execution
> Goal: Run SQL for every PENDING scenario. Record results and findings.

**Trigger:** EDA_SCENARIOS.md is complete
**Input:** EDA_SCENARIOS.md + ddl_docs/*.md + DB connection
**Output:** SQL files in `eda_queries/` + findings in `eda_report/EDA_FINDINGS.md`

### Execution Rules
1. Process HIGH priority scenarios first, then MEDIUM, then LOW.
2. For each scenario: look up the SQL template in `EDA_SQL_TEMPLATES.md`, fill in table/column names from `ddl_docs/`, write to `eda_queries/{scenario_id}.sql`, execute, write finding.
3. After executing each query, update the scenario's Status in `EDA_SCENARIOS.md` to `DONE` or `ERROR`.
4. If a query returns 0 rows (no issue found), still record a PASS finding.
5. If a query errors, record the error, mark `ERROR`, continue to next scenario.

---

## Phase 4 — Summary
> Goal: Produce a clean, human-readable summary of all findings.

**Trigger:** All Phase 3 scenarios are DONE or ERROR
**Input:** `eda_report/EDA_FINDINGS.md`
**Output:** `eda_report/EDA_SUMMARY.md`

### EDA_SUMMARY.md Structure

```markdown
# EDA Summary Report

Database  : {db_name}
Schema    : {schema_name}
Tables    : {count}
Run Date  : {timestamp}

---

## 🔴 HIGH Priority Issues ({count})
| Finding ID | Table | Column | Issue | Recommendation |
|------------|-------|--------|-------|----------------|

## 🟡 MEDIUM Priority Issues ({count})
| Finding ID | Table | Column | Issue | Recommendation |

## 🟢 LOW Priority Issues / Informational ({count})
| Finding ID | Table | Column | Issue | Recommendation |

---

## ✅ Passed Checks ({count})
| Scenario ID | Table | Check |

---

## ❌ Errored Checks ({count})
| Scenario ID | Error Message |

---

## Column Health Heatmap (Text)

| Table | Column | Nulls% | Cardinality | Type OK | Outliers | Overall |
|-------|--------|--------|-------------|---------|----------|---------|
| ...   | ...    | 0%     | HIGH        | ✅      | ✅       | ✅ GOOD |
```