-- ============================================
-- EDA QUERIES FOR mad_dashboard TABLE
-- ============================================

-- 1. BASIC DATA PROFILING
-- ============================================

-- Total record count
SELECT COUNT(*) AS total_records FROM public.mad_dashboard;

-- Sample data preview
SELECT * FROM public.mad_dashboard ORDER BY created_at DESC LIMIT 10;

-- Date range of dashboard snapshots
SELECT 
    MIN(created_at) AS earliest_snapshot,
    MAX(created_at) AS latest_snapshot,
    COUNT(DISTINCT DATE(created_at)) AS distinct_days
FROM public.mad_dashboard;

-- 2. TIER DISTRIBUTION ANALYSIS
-- ============================================

-- Latest tier distribution
SELECT 
    total_count,
    tier1_count,
    tier1_percentage,
    tier2_count,
    tier2_percentage,
    tier3_count,
    tier3_percentage,
    tier4_count,
    tier4_percentage
FROM public.mad_dashboard
ORDER BY created_at DESC
LIMIT 1;

-- Tier counts over time
SELECT 
    DATE(created_at) AS snapshot_date,
    total_count,
    tier1_count,
    tier2_count,
    tier3_count,
    tier4_count
FROM public.mad_dashboard
ORDER BY created_at DESC;

-- Tier percentage validation (should sum to ~100%)
SELECT 
    id,
    created_at,
    COALESCE(tier1_percentage, 0) + 
    COALESCE(tier2_percentage, 0) + 
    COALESCE(tier3_percentage, 0) + 
    COALESCE(tier4_percentage, 0) AS total_percentage
FROM public.mad_dashboard
ORDER BY created_at DESC;

-- 3. ICP DISTRIBUTION ANALYSIS
-- ============================================

-- Latest ICP distribution for individuals
SELECT 
    individual_icp_positive,
    individual_icp_neutral,
    individual_icp_negative,
    icp_unclassified,
    individual_icp_positive + individual_icp_neutral + individual_icp_negative AS total_icp_classified
FROM public.mad_dashboard
ORDER BY created_at DESC
LIMIT 1;

-- ICP sentiment ratio
SELECT 
    created_at,
    ROUND(100.0 * individual_icp_positive / NULLIF(individual_icp_positive + individual_icp_neutral + individual_icp_negative, 0), 2) AS positive_pct,
    ROUND(100.0 * individual_icp_neutral / NULLIF(individual_icp_positive + individual_icp_neutral + individual_icp_negative, 0), 2) AS neutral_pct,
    ROUND(100.0 * individual_icp_negative / NULLIF(individual_icp_positive + individual_icp_neutral + individual_icp_negative, 0), 2) AS negative_pct
FROM public.mad_dashboard
ORDER BY created_at DESC;

-- 4. TEAM SIZE CATEGORY ANALYSIS
-- ============================================

-- Latest team size distribution
SELECT 
    total_teams,
    total_agents_in_teams,
    "Individual",
    "Small",
    "Medium",
    "Large",
    "Mega",
    "Market_Center"
FROM public.mad_dashboard
ORDER BY created_at DESC
LIMIT 1;

-- Average agents per team
SELECT 
    created_at,
    total_teams,
    total_agents_in_teams,
    ROUND(total_agents_in_teams::numeric / NULLIF(total_teams, 0), 2) AS avg_agents_per_team
FROM public.mad_dashboard
WHERE total_teams IS NOT NULL
ORDER BY created_at DESC;

-- 5. BROKERAGE DISTRIBUTION ANALYSIS
-- ============================================

-- Latest brokerage counts
SELECT 
    "KW" AS keller_williams,
    "Remax" AS remax,
    "BHHS" AS berkshire_hathaway,
    "exp_Realty" AS exp_realty,
    "KW" + "Remax" + "BHHS" + "exp_Realty" AS total_major_brokerages
FROM public.mad_dashboard
ORDER BY created_at DESC
LIMIT 1;

-- Brokerage market share
SELECT 
    created_at,
    ROUND(100.0 * "KW" / NULLIF("KW" + "Remax" + "BHHS" + "exp_Realty", 0), 2) AS kw_share,
    ROUND(100.0 * "Remax" / NULLIF("KW" + "Remax" + "BHHS" + "exp_Realty", 0), 2) AS remax_share,
    ROUND(100.0 * "BHHS" / NULLIF("KW" + "Remax" + "BHHS" + "exp_Realty", 0), 2) AS bhhs_share,
    ROUND(100.0 * "exp_Realty" / NULLIF("KW" + "Remax" + "BHHS" + "exp_Realty", 0), 2) AS exp_share
FROM public.mad_dashboard
ORDER BY created_at DESC;

-- 6. ENRICHMENT STATUS ANALYSIS
-- ============================================

-- Not enriched count and percentage
SELECT 
    created_at,
    total_count,
    "Not_Enriched_yet",
    ROUND(100.0 * "Not_Enriched_yet" / NULLIF(total_count, 0), 2) AS not_enriched_pct,
    total_count - "Not_Enriched_yet" AS enriched_count
FROM public.mad_dashboard
ORDER BY created_at DESC;

-- 7. TREND ANALYSIS (if multiple snapshots exist)
-- ============================================

-- Day-over-day changes
SELECT 
    DATE(created_at) AS snapshot_date,
    total_count,
    total_count - LAG(total_count) OVER (ORDER BY created_at) AS total_count_change,
    tier1_count - LAG(tier1_count) OVER (ORDER BY created_at) AS tier1_change,
    tier2_count - LAG(tier2_count) OVER (ORDER BY created_at) AS tier2_change
FROM public.mad_dashboard
ORDER BY created_at DESC;

-- 8. DATA QUALITY CHECKS
-- ============================================

-- Check for null values in key columns
SELECT 
    COUNT(*) AS total_rows,
    COUNT(total_count) AS total_count_filled,
    COUNT(tier1_count) AS tier1_filled,
    COUNT(tier2_count) AS tier2_filled,
    COUNT(tier3_count) AS tier3_filled,
    COUNT(tier4_count) AS tier4_filled,
    COUNT(created_at) AS created_at_filled
FROM public.mad_dashboard;

-- Validate tier counts sum to total
SELECT 
    id,
    created_at,
    total_count,
    COALESCE(tier1_count, 0) + COALESCE(tier2_count, 0) + 
    COALESCE(tier3_count, 0) + COALESCE(tier4_count, 0) AS sum_of_tiers,
    total_count - (COALESCE(tier1_count, 0) + COALESCE(tier2_count, 0) + 
    COALESCE(tier3_count, 0) + COALESCE(tier4_count, 0)) AS difference
FROM public.mad_dashboard
ORDER BY created_at DESC;

-- 9. SUMMARY STATISTICS
-- ============================================

-- Overall statistics across all snapshots
SELECT 
    MIN(total_count) AS min_total,
    MAX(total_count) AS max_total,
    ROUND(AVG(total_count), 0) AS avg_total,
    MIN(tier1_percentage) AS min_tier1_pct,
    MAX(tier1_percentage) AS max_tier1_pct,
    ROUND(AVG(tier1_percentage), 2) AS avg_tier1_pct
FROM public.mad_dashboard;
