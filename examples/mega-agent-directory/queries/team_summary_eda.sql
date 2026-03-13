-- ============================================
-- EDA QUERIES FOR Team_Summary TABLE
-- ============================================

-- 1. BASIC DATA PROFILING
-- ============================================

-- Total record count
SELECT COUNT(*) AS total_records FROM public."Team_Summary";

-- Sample data preview
SELECT * FROM public."Team_Summary" LIMIT 10;   

-- 2. MISSING VALUE ANALYSIS
-- ============================================

SELECT 
    COUNT(*) AS total_rows,
    COUNT(team_name) AS team_name_filled,
    COUNT(*) - COUNT(team_name) AS team_name_missing,
    COUNT(state) AS state_filled,
    COUNT(*) - COUNT(state) AS state_missing,
    COUNT(city) AS city_filled,
    COUNT(*) - COUNT(city) AS city_missing,
    COUNT(brokerage) AS brokerage_filled,
    COUNT(*) - COUNT(brokerage) AS brokerage_missing,
    COUNT(fello_customer_status) AS fello_status_filled,
    COUNT(*) - COUNT(fello_customer_status) AS fello_status_missing,
    COUNT(ai_website) AS ai_website_filled,
    COUNT(*) - COUNT(ai_website) AS ai_website_missing,
    COUNT(rank_2025) AS rank_2025_filled,
    COUNT(*) - COUNT(rank_2025) AS rank_2025_missing
FROM public."Team_Summary";

-- Missing value percentage per column
SELECT 
    ROUND(100.0 * COUNT(*) FILTER (WHERE team_name IS NULL) / COUNT(*), 2) AS team_name_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE state IS NULL) / COUNT(*), 2) AS state_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE city IS NULL) / COUNT(*), 2) AS city_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE team_size_count IS NULL) / COUNT(*), 2) AS team_size_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE sides IS NULL) / COUNT(*), 2) AS sides_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE rank_2025 IS NULL) / COUNT(*), 2) AS rank_2025_null_pct
FROM public."Team_Summary";

-- 3. CATEGORICAL DISTRIBUTION ANALYSIS
-- ============================================

-- Distribution by state
SELECT 
    state, 
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
WHERE state IS NOT NULL
GROUP BY state
ORDER BY team_count DESC
LIMIT 20;

-- Distribution by city
SELECT 
    city, 
    state,
    COUNT(*) AS team_count
FROM public."Team_Summary"
WHERE city IS NOT NULL
GROUP BY city, state
ORDER BY team_count DESC
LIMIT 20;

-- Distribution by source
SELECT 
    source, 
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
GROUP BY source
ORDER BY team_count DESC;

-- Distribution by size category
SELECT 
    size, 
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
GROUP BY size
ORDER BY team_count DESC;

-- Fello customer status distribution
SELECT 
    fello_customer_status, 
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
GROUP BY fello_customer_status
ORDER BY team_count DESC;

-- Brokerage distribution (top 20)
SELECT 
    brokerage, 
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
WHERE brokerage IS NOT NULL
GROUP BY brokerage
ORDER BY team_count DESC
LIMIT 20;

-- 4. NUMERICAL DISTRIBUTION ANALYSIS
-- ============================================

-- Team size statistics
SELECT 
    MIN(team_size_count) AS min_team_size,
    MAX(team_size_count) AS max_team_size,
    ROUND(AVG(team_size_count), 2) AS avg_team_size,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY team_size_count) AS median_team_size,
    ROUND(STDDEV(team_size_count), 2) AS stddev_team_size
FROM public."Team_Summary"
WHERE team_size_count IS NOT NULL;

-- Sides statistics
SELECT 
    MIN(sides) AS min_sides,
    MAX(sides) AS max_sides,
    ROUND(AVG(sides)::numeric, 2) AS avg_sides,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sides) AS median_sides,
    ROUND(STDDEV(sides)::numeric, 2) AS stddev_sides
FROM public."Team_Summary"
WHERE sides IS NOT NULL;

-- Rank 2025 distribution
SELECT 
    MIN(rank_2025) AS min_rank,
    MAX(rank_2025) AS max_rank,
    COUNT(DISTINCT rank_2025) AS distinct_ranks
FROM public."Team_Summary"
WHERE rank_2025 IS NOT NULL;

-- Team size distribution buckets
SELECT 
    CASE 
        WHEN team_size_count <= 5 THEN '1-5'
        WHEN team_size_count <= 10 THEN '6-10'
        WHEN team_size_count <= 25 THEN '11-25'
        WHEN team_size_count <= 50 THEN '26-50'
        WHEN team_size_count <= 100 THEN '51-100'
        ELSE '100+'
    END AS size_bucket,
    COUNT(*) AS team_count
FROM public."Team_Summary"
WHERE team_size_count IS NOT NULL
GROUP BY 1
ORDER BY MIN(team_size_count);

-- 5. CROSS-TABULATION ANALYSIS
-- ============================================

-- Teams by state and fello customer status
SELECT 
    state,
    fello_customer_status,
    COUNT(*) AS team_count
FROM public."Team_Summary"
WHERE state IS NOT NULL
GROUP BY state, fello_customer_status
ORDER BY state, team_count DESC;

-- Average team size by state (top 15 states by team count)
SELECT 
    state,
    COUNT(*) AS team_count,
    ROUND(AVG(team_size_count), 2) AS avg_team_size,
    ROUND(AVG(sides)::numeric, 2) AS avg_sides
FROM public."Team_Summary"
WHERE state IS NOT NULL
GROUP BY state
ORDER BY team_count DESC
LIMIT 15;

-- Size category vs Fello customer status
SELECT 
    size,
    fello_customer_status,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY size, fello_customer_status
ORDER BY size, team_count DESC;

-- 6. ARRAY COLUMN ANALYSIS
-- ============================================

-- Marketing tools usage frequency
SELECT 
    tool,
    COUNT(*) AS usage_count
FROM public."Team_Summary", UNNEST(marketing_tools) AS tool
GROUP BY tool
ORDER BY usage_count DESC;

-- CRM usage frequency
SELECT 
    crm,
    COUNT(*) AS usage_count
FROM public."Team_Summary", UNNEST(team_crm_main) AS crm
GROUP BY crm
ORDER BY usage_count DESC;

-- Teams with multiple CRMs
SELECT 
    COALESCE(array_length(team_crm_main, 1), 0) AS crm_count,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY 1
ORDER BY 1;

-- 7. WEBSITE & DIGITAL PRESENCE ANALYSIS
-- ============================================

-- Teams with website vs without
SELECT 
    CASE 
        WHEN "Website" IS NOT NULL THEN 'Has Website'
        ELSE 'No Website'
    END AS website_status,
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
GROUP BY 1;

-- AI website detection results
SELECT 
    CASE 
        WHEN ai_website IS NOT NULL THEN 'AI Website Found'
        ELSE 'No AI Website'
    END AS ai_website_status,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY 1;

-- 8. DATA QUALITY CHECKS
-- ============================================

-- Duplicate team names check
SELECT 
    team_name, 
    COUNT(*) AS occurrences
FROM public."Team_Summary"
WHERE team_name IS NOT NULL
GROUP BY team_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;

-- Invalid zip codes (not 5 digits)
SELECT 
    zip_code, 
    COUNT(*) AS occurrences
FROM public."Team_Summary"
WHERE zip_code IS NOT NULL 
  AND (LENGTH(zip_code) != 5 OR zip_code !~ '^\d{5}$')
GROUP BY zip_code
ORDER BY occurrences DESC
LIMIT 20;

-- Teams with serper_results populated
SELECT 
    CASE 
        WHEN serper_results IS NOT NULL THEN 'Has Serper Results'
        ELSE 'No Serper Results'
    END AS serper_status,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY 1;

-- 9. TOP/BOTTOM ANALYSIS
-- ============================================

-- Top 10 teams by rank 2025
SELECT 
    team_name,
    rank_2025,
    state,
    city,
    team_size_count,
    sides,
    brokerage
FROM public."Team_Summary"
WHERE rank_2025 IS NOT NULL
ORDER BY rank_2025 ASC
LIMIT 10;

-- Top 10 teams by sides
SELECT 
    team_name,
    sides,
    rank_2025,
    state,
    team_size_count
FROM public."Team_Summary"
WHERE sides IS NOT NULL
ORDER BY sides DESC
LIMIT 10;

-- Top 10 largest teams by size
SELECT 
    team_name,
    team_size_count,
    state,
    city,
    brokerage
FROM public."Team_Summary"
WHERE team_size_count IS NOT NULL
ORDER BY team_size_count DESC
LIMIT 10;

-- 10. ENTITY ANALYSIS
-- ============================================

-- Entity distribution
SELECT 
    entity,
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
GROUP BY entity
ORDER BY team_count DESC;
    ROUND(AVG(team_size_count), 2) AS avg_team_size,
    ROUND(AVG(sides)::numeric, 2) AS avg_sides
FROM public."Team_Summary"
WHERE state IS NOT NULL
GROUP BY state
ORDER BY team_count DESC
LIMIT 15;

Result :
| state | team_count | avg_team_size | avg_sides |
| ----- | ---------- | ------------- | --------- |
| CA    | 7163       | 5.06          | 283.31    |
| FL    | 6908       | 4.84          | 334.98    |
| TX    | 5403       | 5.82          | 370.18    |
| NC    | 2730       | 4.62          | 362.07    |
| NY    | 2483       | 5.51          | 218.33    |
| GA    | 2437       | 6.20          | 1069.25   |
| IL    | 1862       | 6.15          | 264.63    |
| MI    | 1805       | 6.15          | 460.35    |
| CO    | 1646       | 4.08          | 291.04    |
| PA    | 1611       | 9.46          | 326.20    |
| VA    | 1411       | 6.55          | 447.24    |
| TN    | 1374       | 5.92          | 571.21    |
| AZ    | 1306       | 5.01          | 875.11    |
| SC    | 1291       | 5.73          | 406.19    |
| NJ    | 1289       | 7.48          | 349.08    |

-- Size category vs Fello customer status
SELECT 
    size,
    fello_customer_status,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY size, fello_customer_status
ORDER BY size, team_count DESC;

| size       | fello_customer_status | team_count |
| ---------- | --------------------- | ---------- |
| Individual | Not a customer        | 43422      |
| Individual | Customer              | 224        |
| Individual | Churned               | 108        |
| Large      | Not a customer        | 6863       |
| Large      | Customer              | 422        |
| Large      | Churned               | 136        |
| Medium     | Not a customer        | 12497      |
| Medium     | Customer              | 441        |
| Medium     | Churned               | 155        |
| Mega       | Not a customer        | 4921       |
| Mega       | Customer              | 842        |
| Mega       | Churned               | 272        |
| Small      | Not a customer        | 27640      |
| Small      | Customer              | 305        |
| Small      | Churned               | 128        |
-- 6. ARRAY COLUMN ANALYSIS
-- ============================================

-- Marketing tools usage frequency
SELECT 
    tool,
    COUNT(*) AS usage_count
FROM public."Team_Summary", UNNEST(marketing_tools) AS tool
GROUP BY tool
ORDER BY usage_count DESC;

-- CRM usage frequency
SELECT 
    crm,
    COUNT(*) AS usage_count
FROM public."Team_Summary", UNNEST(team_crm_main) AS crm
GROUP BY crm
ORDER BY usage_count DESC;

-- Teams with multiple CRMs
SELECT 
    COALESCE(array_length(team_crm_main, 1), 0) AS crm_count,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY 1
ORDER BY 1;

-- 7. WEBSITE & DIGITAL PRESENCE ANALYSIS
-- ============================================

-- Teams with website vs without
SELECT 
    CASE 
        WHEN "Website" IS NOT NULL THEN 'Has Website'
        ELSE 'No Website'
    END AS website_status,
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
GROUP BY 1;

Result :
| website_status | team_count | percentage |
| -------------- | ---------- | ---------- |
| No Website     | 64056      | 65.11      |
| Has Website    | 34320      | 34.89      |

-- AI website detection results
SELECT 
    CASE 
        WHEN ai_website IS NOT NULL THEN 'AI Website Found'
        ELSE 'No AI Website'
    END AS ai_website_status,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY 1;

Result :
| ai_website_status | team_count |
| ----------------- | ---------- |
| No AI Website     | 50532      |
| AI Website Found  | 47844      |

-- 8. DATA QUALITY CHECKS
-- ============================================

-- Duplicate team names check
SELECT 
    team_name, 
    COUNT(*) AS occurrences
FROM public."Team_Summary"
WHERE team_name IS NOT NULL
GROUP BY team_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;

-- Invalid zip codes (not 5 digits)
SELECT 
    zip_code, 
    COUNT(*) AS occurrences
FROM public."Team_Summary"
WHERE zip_code IS NOT NULL 
  AND (LENGTH(zip_code) != 5 OR zip_code !~ '^\d{5}$')
GROUP BY zip_code
ORDER BY occurrences DESC
LIMIT 20;

-- Teams with serper_results populated
SELECT 
    CASE 
        WHEN serper_results IS NOT NULL THEN 'Has Serper Results'
        ELSE 'No Serper Results'
    END AS serper_status,
    COUNT(*) AS team_count
FROM public."Team_Summary"
GROUP BY 1;

Result :
| serper_status      | team_count |
| ------------------ | ---------- |
| Has Serper Results | 47844      |
| No Serper Results  | 50532      |

-- 9. TOP/BOTTOM ANALYSIS
-- ============================================

-- Top 10 teams by rank 2025
SELECT 
    team_name,
    rank_2025,
    state,
    city,
    team_size_count,
    sides,
    brokerage
FROM public."Team_Summary"
WHERE rank_2025 IS NOT NULL
ORDER BY rank_2025 ASC
LIMIT 10;

-- Top 10 teams by sides
SELECT 
    team_name,
    sides,
    rank_2025,
    state,
    team_size_count
FROM public."Team_Summary"
WHERE sides IS NOT NULL
ORDER BY sides DESC
LIMIT 10;

-- Top 10 largest teams by size
SELECT 
    team_name,
    team_size_count,
    state,
    city,
    brokerage
FROM public."Team_Summary"
WHERE team_size_count IS NOT NULL
ORDER BY team_size_count DESC
LIMIT 10;

-- 10. ENTITY ANALYSIS
-- ============================================

-- Entity distribution
SELECT 
    entity,
    COUNT(*) AS team_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public."Team_Summary"
GROUP BY entity
ORDER BY team_count DESC;

Result :
| entity                 | team_count | percentage |
| ---------------------- | ---------- | ---------- |
| null                   | 82172      | 83.53      |
| Market center KW       | 12711      | 12.92      |
| Brokerage Entity Remax | 3116       | 3.17       |
| Office: BHHS           | 313        | 0.32       |
| Office: AT Properties  | 64         | 0.07       |
