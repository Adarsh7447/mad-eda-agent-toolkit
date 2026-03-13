# EDA SQL Templates
> Agent looks up SQL patterns here by Scenario Category ID.
> Replace ALL placeholders: {schema}, {table}, {column}, {pk_col}, {ref_table}, {ref_col}

---

## Category A — Null & Empty Value Analysis

### A-xx-01: NULL count and percentage per column
```sql
-- Scenario ID : A-{table}-01
-- Table(s)    : {schema}.{table}
-- Phase       : 3
-- Description : NULL count and % per column
-- Generated   : {timestamp}

SELECT
    '{column}'                                           AS column_name,
    COUNT(*)                                             AS total_rows,
    COUNT(*) FILTER (WHERE {column} IS NULL)             AS null_count,
    ROUND(
        COUNT(*) FILTER (WHERE {column} IS NULL)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                    AS null_pct
FROM {schema}.{table};
```
> Agent: Generate one query per column OR use dynamic SQL to produce a union of all columns.

### A-xx-01 (bulk version): All columns in one query using UNPIVOT pattern
```sql
-- Agent: generate one SELECT per column and UNION ALL them
SELECT 'col_name_here' AS column_name,
       COUNT(*) FILTER (WHERE col_name_here IS NULL) AS null_count,
       COUNT(*) AS total_rows
FROM {schema}.{table}
UNION ALL
SELECT 'next_col', COUNT(*) FILTER (WHERE next_col IS NULL), COUNT(*)
FROM {schema}.{table};
```

### A-xx-02: Empty strings in TEXT/VARCHAR columns
```sql
-- Scenario ID : A-{table}-02
-- Description : Empty string count in text columns
SELECT
    '{column}'                                              AS column_name,
    COUNT(*) FILTER (WHERE {column}::text = '')             AS empty_string_count,
    COUNT(*) FILTER (WHERE {column} IS NOT NULL
                       AND {column}::text = '')             AS non_null_empty_count
FROM {schema}.{table};
```

### A-xx-03: Whitespace-only strings
```sql
-- Scenario ID : A-{table}-03
-- Description : Whitespace-only string count
SELECT
    '{column}' AS column_name,
    COUNT(*)   AS whitespace_only_count
FROM {schema}.{table}
WHERE {column} IS NOT NULL
  AND TRIM({column}::text) = ''
  AND {column}::text != '';
```

### A-xx-04: 100% NULL columns
```sql
-- Scenario ID : A-{table}-04
-- Description : Detect fully NULL columns
SELECT
    column_name,
    null_count,
    total_rows,
    CASE WHEN null_count = total_rows THEN 'DEAD COLUMN ⚠️' ELSE 'OK' END AS status
FROM (
    -- Agent: insert bulk null count query here
) null_counts;
```

---

## Category B — Data Type & Format Integrity

### B-xx-01: VARCHAR columns that look like integers
```sql
-- Scenario ID : B-{table}-01
-- Description : TEXT column storing numeric-looking values
SELECT
    '{column}'           AS column_name,
    COUNT(*)             AS numeric_looking_count,
    COUNT(*) FILTER (WHERE {column} !~ '^\-?[0-9]+(\.[0-9]+)?$'
                       AND {column} IS NOT NULL
                       AND {column} != '')  AS non_numeric_count
FROM {schema}.{table}
WHERE {column} IS NOT NULL;
```

### B-xx-02: VARCHAR columns that look like dates
```sql
-- Scenario ID : B-{table}-02
-- Description : TEXT column storing date-looking values
SELECT COUNT(*) AS date_looking_count
FROM {schema}.{table}
WHERE {column} IS NOT NULL
  AND {column} ~ '^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}(:\d{2})?)?$';
```

### B-xx-03: VARCHAR columns that look like booleans
```sql
-- Scenario ID : B-{table}-03
-- Description : TEXT column storing boolean-like values
SELECT {column}, COUNT(*) AS freq
FROM {schema}.{table}
WHERE LOWER({column}::text) IN ('true','false','yes','no','1','0','y','n','t','f')
GROUP BY {column}
ORDER BY freq DESC;
```

### B-xx-04: Unexpectedly negative numeric values
```sql
-- Scenario ID : B-{table}-04
-- Description : Negative values in numeric column
SELECT
    MIN({column})  AS min_value,
    COUNT(*) FILTER (WHERE {column} < 0) AS negative_count
FROM {schema}.{table};
```

### B-xx-05: Consistent short-length TEXT (candidate for ENUM/CHAR)
```sql
-- Scenario ID : B-{table}-05
-- Description : Check if a text column has consistent short length
SELECT
    MIN(LENGTH({column}::text))  AS min_len,
    MAX(LENGTH({column}::text))  AS max_len,
    AVG(LENGTH({column}::text))  AS avg_len,
    COUNT(DISTINCT {column})     AS cardinality
FROM {schema}.{table}
WHERE {column} IS NOT NULL;
```

---

## Category C — Uniqueness & Duplicates

### C-xx-01: PK duplicate check
```sql
-- Scenario ID : C-{table}-01
-- Description : Duplicate primary key values
SELECT {pk_col}, COUNT(*) AS occurrences
FROM {schema}.{table}
GROUP BY {pk_col}
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;
```

### C-xx-02: Fully duplicate rows
```sql
-- Scenario ID : C-{table}-02
-- Description : Fully identical rows
SELECT *, COUNT(*) AS dup_count
FROM {schema}.{table}
GROUP BY {all_columns_comma_separated}
HAVING COUNT(*) > 1
ORDER BY dup_count DESC
LIMIT 20;
```

### C-xx-03: Near-duplicate rows (all cols except PK/timestamp)
```sql
-- Scenario ID : C-{table}-03
-- Description : Near-duplicate rows ignoring PK and timestamp columns
SELECT {non_pk_non_ts_columns}, COUNT(*) AS dup_count
FROM {schema}.{table}
GROUP BY {non_pk_non_ts_columns}
HAVING COUNT(*) > 1
ORDER BY dup_count DESC
LIMIT 20;
```

### C-xx-04: Constant columns (cardinality = 1)
```sql
-- Scenario ID : C-{table}-04
-- Description : Columns with only one distinct value
SELECT COUNT(DISTINCT {column}) AS cardinality
FROM {schema}.{table};
-- If result = 1, column is constant
```

### C-xx-05: Columns with cardinality = row count (natural key candidates)
```sql
-- Scenario ID : C-{table}-05
-- Description : Columns that are effectively unique (natural key candidates)
SELECT
    COUNT(DISTINCT {column}) AS distinct_count,
    COUNT(*)                  AS total_rows,
    CASE WHEN COUNT(DISTINCT {column}) = COUNT(*) THEN 'UNIQUE ✅' ELSE 'NOT UNIQUE' END AS status
FROM {schema}.{table};
```

---

## Category D — Distribution & Outliers

### D-xx-01: Numeric column statistics
```sql
-- Scenario ID : D-{table}-01
-- Description : Min, max, mean, median, stddev for numeric column
SELECT
    MIN({column})                                     AS min_val,
    MAX({column})                                     AS max_val,
    ROUND(AVG({column})::NUMERIC, 4)                  AS mean_val,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY {column}) AS median_val,
    ROUND(STDDEV({column})::NUMERIC, 4)               AS stddev_val,
    COUNT(*) FILTER (WHERE {column} IS NOT NULL)      AS non_null_count
FROM {schema}.{table};
```

### D-xx-02: Outliers (beyond 3 stddev)
```sql
-- Scenario ID : D-{table}-02
-- Description : Outlier rows beyond 3 standard deviations
WITH stats AS (
    SELECT AVG({column}) AS mean_val, STDDEV({column}) AS sd
    FROM {schema}.{table}
)
SELECT {pk_col}, {column}
FROM {schema}.{table}, stats
WHERE ABS({column} - mean_val) > 3 * sd
ORDER BY ABS({column} - mean_val) DESC
LIMIT 20;
```

### D-xx-03: Categorical value distribution
```sql
-- Scenario ID : D-{table}-03
-- Description : Value frequency distribution for low-cardinality column
SELECT
    {column}           AS value,
    COUNT(*)           AS frequency,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM {schema}.{table}
GROUP BY {column}
ORDER BY frequency DESC;
```

### D-xx-04: Suspiciously round values
```sql
-- Scenario ID : D-{table}-04
-- Description : Check if numeric values are all multiples of 10 or 100
SELECT
    COUNT(*) FILTER (WHERE {column} % 10 = 0)  AS multiples_of_10,
    COUNT(*) FILTER (WHERE {column} % 100 = 0) AS multiples_of_100,
    COUNT(*)                                    AS total_non_null
FROM {schema}.{table}
WHERE {column} IS NOT NULL;
```

---

## Category E — Date & Timestamp Checks

### E-xx-01: Date range
```sql
-- Scenario ID : E-{table}-01
-- Description : Min and max date values
SELECT
    MIN({column}) AS earliest,
    MAX({column}) AS latest
FROM {schema}.{table};
```

### E-xx-02: Future dates
```sql
-- Scenario ID : E-{table}-02
-- Description : Rows with date values beyond today
SELECT COUNT(*) AS future_date_count
FROM {schema}.{table}
WHERE {column} > CURRENT_DATE;
```

### E-xx-03: Unrealistically old dates
```sql
-- Scenario ID : E-{table}-03
-- Description : Date values before 1900-01-01
SELECT COUNT(*) AS ancient_date_count
FROM {schema}.{table}
WHERE {column} < '1900-01-01';
```

### E-xx-04: Gaps in time-series (daily granularity)
```sql
-- Scenario ID : E-{table}-04
-- Description : Missing days in a date sequence
WITH date_series AS (
    SELECT generate_series(
        MIN({column}::date),
        MAX({column}::date),
        '1 day'::interval
    )::date AS expected_date
    FROM {schema}.{table}
),
actual_dates AS (
    SELECT DISTINCT {column}::date AS actual_date
    FROM {schema}.{table}
)
SELECT expected_date AS missing_date
FROM date_series
LEFT JOIN actual_dates ON expected_date = actual_date
WHERE actual_date IS NULL
ORDER BY missing_date;
```

### E-xx-05: created_at <= updated_at check
```sql
-- Scenario ID : E-{table}-05
-- Description : Rows where updated_at is before created_at
SELECT COUNT(*) AS invalid_timestamp_count
FROM {schema}.{table}
WHERE updated_at < created_at;
```

---

## Category F — Referential Integrity

### F-xx-01: FK values missing in parent table
```sql
-- Scenario ID : F-{table1}{table2}-01
-- Description : Orphaned FK values
SELECT DISTINCT t1.{fk_col}
FROM {schema}.{table1} t1
LEFT JOIN {schema}.{ref_table} t2
  ON t1.{fk_col} = t2.{ref_col}
WHERE t2.{ref_col} IS NULL
  AND t1.{fk_col} IS NOT NULL
LIMIT 20;
```

### F-xx-02: Orphaned records count
```sql
-- Scenario ID : F-{table1}{table2}-02
-- Description : Count of orphaned rows in child table
SELECT COUNT(*) AS orphaned_count
FROM {schema}.{table1} t1
LEFT JOIN {schema}.{ref_table} t2
  ON t1.{fk_col} = t2.{ref_col}
WHERE t2.{ref_col} IS NULL;
```

### F-xx-03: Join cardinality
```sql
-- Scenario ID : F-{table1}{table2}-03
-- Description : Determine join cardinality between two tables
SELECT
    COUNT(DISTINCT t1.{pk_col})  AS unique_parent_keys,
    COUNT(DISTINCT t2.{fk_col})  AS unique_child_fk_values,
    COUNT(t2.{fk_col})           AS total_child_rows
FROM {schema}.{ref_table} t1
LEFT JOIN {schema}.{table1} t2 ON t1.{pk_col} = t2.{fk_col};
```

---

## Category G — String Quality

### G-xx-01: Leading/trailing whitespace
```sql
-- Scenario ID : G-{table}-01
-- Description : Text values with leading or trailing whitespace
SELECT COUNT(*) AS whitespace_padded_count
FROM {schema}.{table}
WHERE {column} IS NOT NULL
  AND ({column} != TRIM({column}));
```

### G-xx-02: Mixed case inconsistencies
```sql
-- Scenario ID : G-{table}-02
-- Description : Case variations of same value
SELECT LOWER({column}) AS normalised_value, array_agg(DISTINCT {column}) AS variants, COUNT(*)
FROM {schema}.{table}
WHERE {column} IS NOT NULL
GROUP BY LOWER({column})
HAVING COUNT(DISTINCT {column}) > 1
ORDER BY COUNT(*) DESC
LIMIT 20;
```

### G-xx-03: Special/control characters
```sql
-- Scenario ID : G-{table}-03
-- Description : Values containing non-printable or special characters
SELECT COUNT(*) AS special_char_count
FROM {schema}.{table}
WHERE {column} ~ '[^\x20-\x7E]';
```

### G-xx-04: Email format check
```sql
-- Scenario ID : G-{table}-04
-- Description : Email values failing basic format check
SELECT {column}, COUNT(*) AS invalid_count
FROM {schema}.{table}
WHERE {column} IS NOT NULL
  AND {column} !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
GROUP BY {column}
ORDER BY invalid_count DESC
LIMIT 20;
```

### G-xx-05: Inconsistent length in ID/phone/zip columns
```sql
-- Scenario ID : G-{table}-05
-- Description : Length distribution for structured string column
SELECT
    LENGTH({column}) AS value_length,
    COUNT(*)         AS frequency
FROM {schema}.{table}
WHERE {column} IS NOT NULL
GROUP BY LENGTH({column})
ORDER BY frequency DESC;
```