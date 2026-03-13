-- ============================================
-- EDA QUERIES FOR new_unified_agents TABLE
-- ============================================

-- 1. BASIC DATA PROFILING
-- ============================================

-- Total record count
SELECT COUNT(1) AS total_agents FROM public.new_unified_agents;

-- Sample data preview
SELECT * FROM public.new_unified_agents LIMIT 10;

-- Date range of updates
SELECT 
    MIN(updated_at) AS earliest_update,
    MAX(updated_at) AS latest_update
FROM public.new_unified_agents;

-- 2. MISSING VALUE ANALYSIS
-- ============================================

-- Key fields null percentage
SELECT 
    COUNT(*) AS total_rows,
    ROUND(100.0 * COUNT(*) FILTER (WHERE full_name IS NULL) / COUNT(*), 2) AS full_name_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE email IS NULL OR array_length(email, 1) IS NULL) / COUNT(*), 2) AS email_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE phone IS NULL OR array_length(phone, 1) IS NULL) / COUNT(*), 2) AS phone_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE state IS NULL OR array_length(state, 1) IS NULL) / COUNT(*), 2) AS state_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE team_id IS NULL OR team_id = '') / COUNT(*), 2) AS team_id_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE brokerage_name IS NULL) / COUNT(*), 2) AS brokerage_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE experience_years IS NULL) / COUNT(*), 2) AS experience_null_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "CRM" IS NULL) / COUNT(*), 2) AS crm_null_pct
FROM public.new_unified_agents;

-- 3. GEOGRAPHIC DISTRIBUTION
-- ============================================

-- Distribution by state (unnested)
SELECT 
    s AS state,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents, UNNEST(state) AS s
GROUP BY s
ORDER BY agent_count DESC
LIMIT 20;

-- Distribution by city (top 20)
SELECT 
    c AS city,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(city) AS c
WHERE c IS NOT NULL
GROUP BY c
ORDER BY agent_count DESC
LIMIT 20;

-- 4. TEAM ANALYSIS
-- ============================================

-- Team vs Individual agents
SELECT 
    CASE 
        WHEN team_id IS NULL OR team_id = '' THEN 'Individual'
        ELSE 'Team Member'
    END AS agent_type,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
GROUP BY 1;

-- Team size distribution
SELECT 
    team_size,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
WHERE team_size IS NOT NULL
GROUP BY team_size
ORDER BY agent_count DESC;

-- Team size count statistics
SELECT 
    MIN(team_size_count) AS min_team_size,
    MAX(team_size_count) AS max_team_size,
    ROUND(AVG(team_size_count), 2) AS avg_team_size,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY team_size_count) AS median_team_size
FROM public.new_unified_agents
WHERE team_size_count IS NOT NULL;

-- Zillow team status distribution
SELECT 
    zillow_team_status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY zillow_team_status
ORDER BY agent_count DESC;

-- 5. BROKERAGE ANALYSIS
-- ============================================

-- Top brokerages
SELECT 
    brokerage_name,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
WHERE brokerage_name IS NOT NULL
GROUP BY brokerage_name
ORDER BY agent_count DESC
LIMIT 20;

-- Brokerage from main array
SELECT 
    b AS brokerage,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(brokerage_name_main) AS b
WHERE b IS NOT NULL
GROUP BY b
ORDER BY agent_count DESC
LIMIT 20;

-- 6. CRM & MARKETING TOOLS ANALYSIS
-- ============================================

-- CRM distribution
SELECT 
    "CRM",
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
WHERE "CRM" IS NOT NULL
GROUP BY "CRM"
ORDER BY agent_count DESC
LIMIT 20;

-- CRM main array analysis
SELECT 
    crm,
    COUNT(*) AS usage_count
FROM public.new_unified_agents, UNNEST(crm_main) AS crm
WHERE crm IS NOT NULL
GROUP BY crm
ORDER BY usage_count DESC;

-- Marketing tools distribution
SELECT 
    m AS marketing_tool,
    COUNT(*) AS usage_count
FROM public.new_unified_agents, UNNEST(marketing_main) AS m
WHERE m IS NOT NULL
GROUP BY m
ORDER BY usage_count DESC
LIMIT 20;

-- 7. EXPERIENCE & PERFORMANCE ANALYSIS
-- ============================================

-- Experience years distribution
SELECT 
    CASE 
        WHEN experience_years <= 2 THEN '0-2 years'
        WHEN experience_years <= 5 THEN '3-5 years'
        WHEN experience_years <= 10 THEN '6-10 years'
        WHEN experience_years <= 20 THEN '11-20 years'
        ELSE '20+ years'
    END AS experience_bucket,
    COUNT(*) AS agent_count,
    ROUND(AVG(total_sales), 0) AS avg_total_sales
FROM public.new_unified_agents
WHERE experience_years IS NOT NULL
GROUP BY 1
ORDER BY MIN(experience_years);

-- Experience statistics
SELECT 
    MIN(experience_years) AS min_exp,
    MAX(experience_years) AS max_exp,
    ROUND(AVG(experience_years), 2) AS avg_exp,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY experience_years) AS median_exp
FROM public.new_unified_agents
WHERE experience_years IS NOT NULL;

-- Total sales statistics
SELECT 
    MIN(total_sales) AS min_sales,
    MAX(total_sales) AS max_sales,
    ROUND(AVG(total_sales), 0) AS avg_sales,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) AS median_sales
FROM public.new_unified_agents
WHERE total_sales IS NOT NULL;

-- Average price statistics
SELECT 
    MIN(average_price) AS min_avg_price,
    MAX(average_price) AS max_avg_price,
    ROUND(AVG(average_price), 2) AS avg_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_price) AS median_price
FROM public.new_unified_agents
WHERE average_price IS NOT NULL;

-- 8. RATINGS & REVIEWS ANALYSIS
-- ============================================

-- Zillow ratings distribution
SELECT 
    CASE 
        WHEN zillow_rating >= 4.5 THEN '4.5-5.0'
        WHEN zillow_rating >= 4.0 THEN '4.0-4.4'
        WHEN zillow_rating >= 3.0 THEN '3.0-3.9'
        ELSE 'Below 3.0'
    END AS rating_bucket,
    COUNT(*) AS agent_count,
    ROUND(AVG(zillow_review), 0) AS avg_review_count
FROM public.new_unified_agents
WHERE zillow_rating IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

-- Rating comparison across platforms
SELECT 
    ROUND(AVG(zillow_rating)::numeric, 2) AS avg_zillow_rating,
    ROUND(AVG(google_rating)::numeric, 2) AS avg_google_rating,
    ROUND(AVG(realtor_rating)::numeric, 2) AS avg_realtor_rating,
    ROUND(AVG(zillow_review)::numeric, 0) AS avg_zillow_reviews,
    ROUND(AVG(google_rating_count)::numeric, 0) AS avg_google_reviews,
    ROUND(AVG(realtor_review)::numeric, 0) AS avg_realtor_reviews
FROM public.new_unified_agents;

-- Top agents by Zillow rating (with min review count)
SELECT 
    full_name,
    zillow_rating,
    zillow_review,
    zillow_top_agent,
    brokerage_name
FROM public.new_unified_agents
WHERE zillow_rating IS NOT NULL AND zillow_review >= 10
ORDER BY zillow_rating DESC, zillow_review DESC
LIMIT 20;

-- 9. PREMIUM STATUS ANALYSIS
-- ============================================

-- Zillow premium distribution
SELECT 
    zillow_premium,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
GROUP BY zillow_premium
ORDER BY agent_count DESC;

-- Realtor premium distribution
SELECT 
    realtor_premium,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
GROUP BY realtor_premium
ORDER BY agent_count DESC;

-- Zillow top agent distribution
SELECT 
    zillow_top_agent,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY zillow_top_agent
ORDER BY agent_count DESC;

-- 10. SOCIAL MEDIA PRESENCE ANALYSIS
-- ============================================

-- Social media presence summary
SELECT 
    COUNT(*) FILTER (WHERE facebook IS NOT NULL) AS has_facebook,
    COUNT(*) FILTER (WHERE instagram IS NOT NULL) AS has_instagram,
    COUNT(*) FILTER (WHERE linkedin IS NOT NULL) AS has_linkedin,
    COUNT(*) FILTER (WHERE youtube IS NOT NULL) AS has_youtube,
    COUNT(*) FILTER (WHERE twitter IS NOT NULL) AS has_twitter,
    COUNT(*) FILTER (WHERE tiktok IS NOT NULL) AS has_tiktok,
    COUNT(*) AS total_agents
FROM public.new_unified_agents;

-- Social score distribution
SELECT 
    CASE 
        WHEN "social_Score" = 0 OR "social_Score" IS NULL THEN 'No Score'
        WHEN "social_Score" <= 25 THEN 'Low (1-25)'
        WHEN "social_Score" <= 50 THEN 'Medium (26-50)'
        WHEN "social_Score" <= 75 THEN 'High (51-75)'
        ELSE 'Very High (76+)'
    END AS social_score_bucket,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY 1
ORDER BY MIN(COALESCE("social_Score", 0));

-- Social label distribution
SELECT 
    social_label,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
WHERE social_label IS NOT NULL
GROUP BY social_label
ORDER BY agent_count DESC;

-- 11. FELLO CUSTOMER ANALYSIS
-- ============================================

-- Fello customer status distribution
SELECT 
    fello_customer_status,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
GROUP BY fello_customer_status
ORDER BY agent_count DESC;

-- Fello customer status from main array
SELECT 
    status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(fello_customer_status_main) AS status
WHERE status IS NOT NULL
GROUP BY status
ORDER BY agent_count DESC;

-- Agents linked to Fello customers
SELECT 
    COUNT(*) FILTER (WHERE fello_customer_uuid IS NOT NULL) AS linked_to_fello,
    COUNT(*) FILTER (WHERE fello_customer_uuid IS NULL) AS not_linked,
    COUNT(*) AS total
FROM public.new_unified_agents;

-- 12. SOURCE ANALYSIS
-- ============================================

-- Data source distribution
SELECT 
    src AS source,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(source) AS src
WHERE src IS NOT NULL
GROUP BY src
ORDER BY agent_count DESC;

-- Agents with multiple sources
SELECT 
    COALESCE(array_length(source, 1), 0) AS source_count,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY 1
ORDER BY 1;

-- 13. ENTITY TYPE ANALYSIS
-- ============================================

-- Entity distribution
SELECT 
    e AS entity,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(entity) AS e
WHERE e IS NOT NULL
GROUP BY e
ORDER BY agent_count DESC;

-- 14. DATA QUALITY CHECKS
-- ============================================

-- Duplicate full names
SELECT 
    full_name,
    COUNT(*) AS occurrences
FROM public.new_unified_agents
WHERE full_name IS NOT NULL
GROUP BY full_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;

-- Agents with website
SELECT 
    CASE 
        WHEN website IS NOT NULL OR website_clean IS NOT NULL THEN 'Has Website'
        ELSE 'No Website'
    END AS website_status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY 1;

-- Review status distribution
SELECT 
    review_status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY review_status
ORDER BY agent_count DESC;

-- Primary contact analysis
SELECT 
    is_primary_contact,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY is_primary_contact;

-- 15. CROSS-TABULATION ANALYSIS
-- ============================================

-- Team size vs Fello customer status
SELECT 
    team_size,
    fello_customer_status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
WHERE team_size IS NOT NULL
GROUP BY team_size, fello_customer_status
ORDER BY team_size, agent_count DESC;

-- Experience vs Average price correlation
SELECT 
    CASE 
        WHEN experience_years <= 5 THEN '0-5 years'
        WHEN experience_years <= 10 THEN '6-10 years'
        WHEN experience_years <= 20 THEN '11-20 years'
        ELSE '20+ years'
    END AS experience_bucket,
    COUNT(*) AS agent_count,
    ROUND(AVG(average_price), 0) AS avg_price,
    ROUND(AVG(total_sales), 0) AS avg_sales
FROM public.new_unified_agents
WHERE experience_years IS NOT NULL
GROUP BY 1
ORDER BY MIN(experience_years);

-- Luxury agents KW
SELECT 
    is_luxury_agents_kw,
    COUNT(*) AS agent_count,
    ROUND(AVG(average_price), 0) AS avg_price
FROM public.new_unified_agents
GROUP BY is_luxury_agents_kw;
| inside real estate                                                             | 1           |

-- Marketing tools distribution
SELECT 
    m AS marketing_tool,
    COUNT(*) AS usage_count
FROM public.new_unified_agents, UNNEST(marketing_main) AS m
WHERE m IS NOT NULL
GROUP BY m
ORDER BY usage_count DESC
LIMIT 20;

Result :
| marketing_tool               | usage_count |
| ---------------------------- | ----------- |
|  WordPress                   | 46897       |
| WordPress                    | 30396       |
|  Google Analytics            | 28638       |
|  Google Analytics 4          | 24487       |
|  Global Site Tag             | 20337       |
|  Facebook Pixel              | 14287       |
|  Google Universal Analytics  | 14044       |
|  ListTrac                    | 13920       |
|  LiveBy                      | 11201       |
|  Google AdWords Conversion   | 11189       |
|  Percy AI                    | 9140        |
|  WordPress 6.8               | 8945        |
|  Atlassian Cloud             | 8320        |
| Facebook Conversion Tracking | 8061        |
|  Luxury Presence             | 7749        |
|  Windermere Real Estate      | 7509        |
|  Squarespace                 | 7492        |
|  Google Conversion Tracking  | 7243        |
| Adfenix                      | 7100        |
|  Wix                         | 6943        |

-- 7. EXPERIENCE & PERFORMANCE ANALYSIS
-- ============================================

-- Experience years distribution
SELECT 
    CASE 
        WHEN experience_years <= 2 THEN '0-2 years'
        WHEN experience_years <= 5 THEN '3-5 years'
        WHEN experience_years <= 10 THEN '6-10 years'
        WHEN experience_years <= 20 THEN '11-20 years'
        ELSE '20+ years'
    END AS experience_bucket,
    COUNT(*) AS agent_count,
    ROUND(AVG(total_sales), 0) AS avg_total_sales
FROM public.new_unified_agents
WHERE experience_years IS NOT NULL
GROUP BY 1
ORDER BY MIN(experience_years);

Result :
| experience_bucket | agent_count | avg_total_sales |
| ----------------- | ----------- | --------------- |
| 0-2 years         | 48658       | 13              |
| 3-5 years         | 69256       | 89509           |
| 6-10 years        | 101541      | 70              |
| 11-20 years       | 138427      | 85              |
| 20+ years         | 171449      | 96              |

-- Experience statistics
SELECT 
    MIN(experience_years) AS min_exp,
    MAX(experience_years) AS max_exp,
    ROUND(AVG(experience_years), 2) AS avg_exp,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY experience_years) AS median_exp
FROM public.new_unified_agents
WHERE experience_years IS NOT NULL;

Result :
| min_exp | max_exp | avg_exp | median_exp |
| ------- | ------- | ------- | ---------- |
| 0       | 4020    | 377.15  | 15         |

-- Total sales statistics
SELECT 
    MIN(total_sales) AS min_sales,
    MAX(total_sales) AS max_sales,
    ROUND(AVG(total_sales), 0) AS avg_sales,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) AS median_sales
FROM public.new_unified_agents
WHERE total_sales IS NOT NULL;

Result :
| min_sales | max_sales  | avg_sales | median_sales |
| --------- | ---------- | --------- | ------------ |
| 0         | 3817200121 | 15011     | 35           |

-- Average price statistics
SELECT 
    MIN(average_price) AS min_avg_price,
    MAX(average_price) AS max_avg_price,
    ROUND(AVG(average_price), 2) AS avg_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_price) AS median_price
FROM public.new_unified_agents
WHERE average_price IS NOT NULL;

Result :
| min_avg_price | max_avg_price | avg_price | median_price |
| ------------- | ------------- | --------- | ------------ |
| 0             | 49000000      | 40409.24  | 306.2        |

-- 8. RATINGS & REVIEWS ANALYSIS
-- ============================================

-- Zillow ratings distribution
SELECT 
    CASE 
        WHEN zillow_rating >= 4.5 THEN '4.5-5.0'
        WHEN zillow_rating >= 4.0 THEN '4.0-4.4'
        WHEN zillow_rating >= 3.0 THEN '3.0-3.9'
        ELSE 'Below 3.0'
    END AS rating_bucket,
    COUNT(*) AS agent_count,
    ROUND(AVG(zillow_review), 0) AS avg_review_count
FROM public.new_unified_agents
WHERE zillow_rating IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

Result :
| rating_bucket | agent_count | avg_review_count |
| ------------- | ----------- | ---------------- |
| Below 3.0     | 3366        | -1               |
| 4.5-5.0       | 12054       | 30               |
| 4.0-4.4       | 85          | 6                |
| 3.0-3.9       | 55          | 3                |

-- Rating comparison across platforms
SELECT 
    ROUND(AVG(zillow_rating)::numeric, 2) AS avg_zillow_rating,
    ROUND(AVG(google_rating)::numeric, 2) AS avg_google_rating,
    ROUND(AVG(realtor_rating)::numeric, 2) AS avg_realtor_rating,
    ROUND(AVG(zillow_review)::numeric, 0) AS avg_zillow_reviews,
    ROUND(AVG(google_rating_count)::numeric, 0) AS avg_google_reviews,
    ROUND(AVG(realtor_review)::numeric, 0) AS avg_realtor_reviews
FROM public.new_unified_agents;

Result : 
| avg_zillow_rating | avg_google_rating | avg_realtor_rating | avg_zillow_reviews | avg_google_reviews | avg_realtor_reviews |
| ----------------- | ----------------- | ------------------ | ------------------ | ------------------ | ------------------- |
| 3.69              | 2.85              | 0.88               | 23                 | 40                 | 2                   |

-- Top agents by Zillow rating (with min review count)
SELECT 
    full_name,
    zillow_rating,
    zillow_review,
    zillow_top_agent,
    brokerage_name
FROM public.new_unified_agents
WHERE zillow_rating IS NOT NULL AND zillow_review >= 10
ORDER BY zillow_rating DESC, zillow_review DESC
LIMIT 20;

| full_name             | zillow_rating | zillow_review | zillow_top_agent | brokerage_name                     |
| --------------------- | ------------- | ------------- | ---------------- | ---------------------------------- |
| Michael Tyszka        | 5             | 994           | Top Agent        | Keller Williams Realty Cherry Hill |
| Jennifer Landro       | 5             | 987           | Top Agent        | NA                                 |
| Treasure Davis        | 5             | 975           | Top Agent        | eXp Realty                         |
| Jen Marie             | 5             | 974           | Top Agent        | NA                                 |
| Andy Bovender         | 5             | 974           | NA               | Compass                            |
| Ron Howard            | 5             | 971           | Top Agent        | RE/MAX Advantage Realty            |
| Kirby Scofield        | 5             | 956           | Top Agent        | LPT Realty                         |
| Scot Brothers         | 5             | 943           | Top Agent        | eXp Realty                         |
| Bob And Ronna         | 5             | 940           | Top Agent        | Samson Properties                  |
| Brett Sikora          | 5             | 939           | Top Agent        | NA                                 |
| Gusty Gulas           | 5             | 919           | Top Agent        | eXp Realty                         |
| Mike Smallegan        | 5             | 875           | Top Agent        | Keller Williams                    |
| Sandra Rathe          | 5             | 871           | NA               | Keller Williams                    |
| Stephanie Younger     | 5             | 857           | Top Agent        | Compass                            |
| Matt Tessier          | 5             | 845           | Top Agent        | NA                                 |
| Culbertson Gray Group | 5             | 820           | Top Agent        | eXp Realty Inc.                    |
| Brittany Gibbs        | 5             | 820           | Top Agent        | Move Real Estate                   |
| Jenny Maraghy         | 5             | 795           | Top Agent        | Compass                            |
| Rob Kittle            | 5             | 787           | Top Agent        | Kittle Real Estate                 |
| Remelie Codilla       | 5             | 780           | NA               | PhillyLiving Management Group      |

-- 9. PREMIUM STATUS ANALYSIS
-- ============================================

-- Zillow premium distribution
SELECT 
    zillow_premium,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
GROUP BY zillow_premium
ORDER BY agent_count DESC;

Result :
| zillow_premium | agent_count | percentage |
| -------------- | ----------- | ---------- |
| null           | 1057773     | 98.16      |
| NA             | 9733        | 0.90       |
| no             | 9386        | 0.87       |
| Premier        | 571         | 0.05       |
| yes            | 106         | 0.01       |

-- Realtor premium distribution
SELECT 
    realtor_premium,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
GROUP BY realtor_premium
ORDER BY agent_count DESC;

Result :
| realtor_premium | agent_count | percentage |
| --------------- | ----------- | ---------- |
| null            | 976780      | 90.65      |
| NA              | 97705       | 9.07       |
|                 | 2581        | 0.24       |
| Premium         | 503         | 0.05       |

-- Zillow top agent distribution
SELECT 
    zillow_top_agent,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY zillow_top_agent
ORDER BY agent_count DESC;

Result :
| zillow_top_agent | agent_count |
| ---------------- | ----------- |
| null             | 1067240     |
| NA               | 6733        |
| Top Agent        | 3596        |

-- 10. SOCIAL MEDIA PRESENCE ANALYSIS
-- ============================================

-- Social media presence summary
SELECT 
    COUNT(*) FILTER (WHERE facebook IS NOT NULL) AS has_facebook,
    COUNT(*) FILTER (WHERE instagram IS NOT NULL) AS has_instagram,
    COUNT(*) FILTER (WHERE linkedin IS NOT NULL) AS has_linkedin,
    COUNT(*) FILTER (WHERE youtube IS NOT NULL) AS has_youtube,
    COUNT(*) FILTER (WHERE twitter IS NOT NULL) AS has_twitter,
    COUNT(*) FILTER (WHERE tiktok IS NOT NULL) AS has_tiktok,
    COUNT(*) AS total_agents
FROM public.new_unified_agents;

Result :
| has_facebook | has_instagram | has_linkedin | has_youtube | has_twitter | has_tiktok | total_agents |
| ------------ | ------------- | ------------ | ----------- | ----------- | ---------- | ------------ |
| 330444       | 153417        | 200756       | 48685       | 41659       | 19088      | 1077569      |

-- Social score distribution
SELECT 
    CASE 
        WHEN "social_Score" = 0 OR "social_Score" IS NULL THEN 'No Score'
        WHEN "social_Score" <= 25 THEN 'Low (1-25)'
        WHEN "social_Score" <= 50 THEN 'Medium (26-50)'
        WHEN "social_Score" <= 75 THEN 'High (51-75)'
        ELSE 'Very High (76+)'
    END AS social_score_bucket,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY 1
ORDER BY MIN(COALESCE("social_Score", 0));

Result :
| social_score_bucket | agent_count |
| ------------------- | ----------- |
| No Score            | 954284      |
| Low (1-25)          | 123285      |

-- Social label distribution
SELECT 
    social_label,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
WHERE social_label IS NOT NULL
GROUP BY social_label
ORDER BY agent_count DESC;

| social_label     | agent_count |
| ---------------- | ----------- |
| poor             | 55122       |
| good             | 45099       |
| medium           | 44564       |
| none             | 9           |
| low              | 3           |
| no socials found | 2           |

-- 11. FELLO CUSTOMER ANALYSIS
-- ============================================

-- Fello customer status distribution
SELECT 
    fello_customer_status,
    COUNT(*) AS agent_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM public.new_unified_agents
GROUP BY fello_customer_status
ORDER BY agent_count DESC;

Result :
| fello_customer_status | agent_count | percentage |
| --------------------- | ----------- | ---------- |
| null                  | 1061613     | 98.52      |
| Customer              | 11276       | 1.05       |
| Churned               | 4401        | 0.41       |
| Churn                 | 279         | 0.03       |

-- Fello customer status from main array
SELECT 
    status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(fello_customer_status_main) AS status
WHERE status IS NOT NULL
GROUP BY status
ORDER BY agent_count DESC;

Result :
| status   | agent_count |
| -------- | ----------- |
| Customer | 12147       |
| Churned  | 4401        |
| Churn    | 279         |

-- Agents linked to Fello customers
SELECT 
    COUNT(*) FILTER (WHERE fello_customer_uuid IS NOT NULL) AS linked_to_fello,
    COUNT(*) FILTER (WHERE fello_customer_uuid IS NULL) AS not_linked,
    COUNT(*) AS total
FROM public.new_unified_agents;

Result :
| linked_to_fello | not_linked | total   |
| --------------- | ---------- | ------- |
| 15956           | 1061613    | 1077569 |

-- 12. SOURCE ANALYSIS
-- ============================================

-- Data source distribution
SELECT 
    src AS source,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(source) AS src
WHERE src IS NOT NULL
GROUP BY src
ORDER BY agent_count DESC;

Result :
| source                              | agent_count |
| ----------------------------------- | ----------- |
| Data_Realtor                        | 308802      |
| Data_Homes                          | 234982      |
| Data_Maps                           | 221214      |
| Data_KW                             | 112412      |
| Company_Info                        | 52648       |
| Data_Remax                          | 46334       |
| Data_BHHS                           | 43952       |
| Data_OneReal                        | 27050       |
| Data_BetterHomes                    | 10093       |
| agents_1                            | 8704        |
| agents_duplicate_confidence_table   | 6663        |
| agents_3                            | 6362        |
| agents_2                            | 5801        |
| Data_AT_Properties                  | 4591        |
| Data_Epique                         | 3888        |
| agents_3_duplicate_confidence_table | 3764        |
| agents_2_duplicate_confidence_table | 1510        |

-- Agents with multiple sources
SELECT 
    COALESCE(array_length(source, 1), 0) AS source_count,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY 1
ORDER BY 1;

Result :
| source_count | agent_count |
| ------------ | ----------- |
| 0            | 1123        |
| 1            | 1054730     |
| 2            | 21123       |
| 3            | 578         |
| 4            | 15          |

-- 13. ENTITY TYPE ANALYSIS
-- ============================================

-- Entity distribution
SELECT 
    e AS entity,
    COUNT(*) AS agent_count
FROM public.new_unified_agents, UNNEST(entity) AS e
WHERE e IS NOT NULL
GROUP BY e
ORDER BY agent_count DESC;

Result :
No records with non-null entity values, indicating that this field may not have been populated or is not applicable to the agents in the dataset.

-- 14. DATA QUALITY CHECKS
-- ============================================

-- Duplicate full names
SELECT 
    full_name,
    COUNT(*) AS occurrences
FROM public.new_unified_agents
WHERE full_name IS NOT NULL
GROUP BY full_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;

Result :
| full_name                 | occurrences |
| ------------------------- | ----------- |
| Hilary Saunders           | 151         |
| Na                        | 109         |
| Frank Martell             | 94          |
| Josh McCarter             | 94          |
| Ori Allon                 | 94          |
| Steven Sordello           | 94          |
| Dawanna Williams          | 94          |
| Allan Leinwand            | 94          |
| Pamela Thomas-Graham      | 94          |
| Robert Reffkin            | 94          |
| Scott Wahlers             | 90          |
| Rory Golod                | 90          |
| Neda Navab                | 90          |
| Richard "Ric" Martel, Jr. | 82          |
| The Group                 | 78          |
| Michael Smith             | 60          |
| Deborah Penny             | 60          |
|                           | 59          |
| Larry Knapp               | 59          |
| Dave Wetzel               | 58          |

-- Agents with website
SELECT 
    CASE 
        WHEN website IS NOT NULL OR website_clean IS NOT NULL THEN 'Has Website'
        ELSE 'No Website'
    END AS website_status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY 1;

Result :
| website_status | agent_count |
| -------------- | ----------- |
| No Website     | 684587      |
| Has Website    | 392982      |

-- Review status distribution
SELECT 
    review_status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY review_status
ORDER BY agent_count DESC;

Result :
| review_status | agent_count |
| ------------- | ----------- |
| null          | 1072977     |
| updated       | 2581        |
| update        | 1981        |
| new_delete    | 29          |
|               | 1           |

-- Primary contact analysis
SELECT 
    is_primary_contact,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
GROUP BY is_primary_contact;

| is_primary_contact | agent_count |
| ------------------ | ----------- |
| true               | 32329       |
| null               | 1045240     |

-- 15. CROSS-TABULATION ANALYSIS
-- ============================================

-- Team size vs Fello customer status
SELECT 
    team_size,
    fello_customer_status,
    COUNT(*) AS agent_count
FROM public.new_unified_agents
WHERE team_size IS NOT NULL
GROUP BY team_size, fello_customer_status
ORDER BY team_size, agent_count DESC;

| team_size  | fello_customer_status | agent_count |
| ---------- | --------------------- | ----------- |
| -1         | null                  | 136         |
| 0          | null                  | 5           |
| 1          | null                  | 41          |
| 12         | null                  | 1           |
| 13         | null                  | 1           |
| 15         | null                  | 3           |
| 164        | null                  | 1           |
| 18         | null                  | 2           |
| 2          | null                  | 7           |
| 20         | null                  | 1           |
| 21         | null                  | 1           |
| 221        | null                  | 1           |
| 24         | null                  | 1           |
| 29         | null                  | 1           |
| 3          | null                  | 4           |
| 30         | null                  | 1           |
| 34         | null                  | 1           |
| 356        | null                  | 1           |
| 36         | null                  | 1           |
| 4          | null                  | 5           |
| 44         | null                  | 1           |
| 49         | null                  | 1           |
| 6          | null                  | 2           |
| 600        | null                  | 1           |
| 621        | null                  | 1           |
| 7          | null                  | 3           |
| 8          | null                  | 4           |
| 81         | null                  | 1           |
| 86         | null                  | 1           |
| 9          | null                  | 1           |
| Individual | null                  | 154922      |
| Individual | Customer              | 1854        |
| Individual | Churned               | 751         |
| Individual | Churn                 | 50          |
| Large      | null                  | 28436       |
| Large      | Customer              | 825         |
| Large      | Churned               | 213         |
| Large      | Churn                 | 18          |
| Medium     | null                  | 22538       |
| Medium     | Customer              | 448         |
| Medium     | Churned               | 176         |
| Medium     | Churn                 | 12          |
| Mega       | null                  | 51017       |
| Mega       | Customer              | 910         |
| Mega       | Churned               | 313         |
| Mega       | Churn                 | 10          |
| Small      | null                  | 37800       |
| Small      | Customer              | 648         |
| Small      | Churned               | 264         |
| Small      | Churn                 | 31          |
| Unknown    | null                  | 137996      |
| Unknown    | Customer              | 1439        |
| Unknown    | Churned               | 589         |
| Unknown    | Churn                 | 24          |

-- Experience vs Average price correlation
SELECT 
    CASE 
        WHEN experience_years <= 5 THEN '0-5 years'
        WHEN experience_years <= 10 THEN '6-10 years'
        WHEN experience_years <= 20 THEN '11-20 years'
        ELSE '20+ years'
    END AS experience_bucket,
    COUNT(*) AS agent_count,
    ROUND(AVG(average_price), 0) AS avg_price,
    ROUND(AVG(total_sales), 0) AS avg_sales
FROM public.new_unified_agents
WHERE experience_years IS NOT NULL
GROUP BY 1
ORDER BY MIN(experience_years);

Result :
| experience_bucket | agent_count | avg_price | avg_sales |
| ----------------- | ----------- | --------- | --------- |
| 0-5 years         | 117914      | 2598      | 54717     |
| 6-10 years        | 101541      | 3774      | 70        |
| 11-20 years       | 138427      | 5062      | 85        |
| 20+ years         | 171449      | 13580     | 96        |

-- Luxury agents KW
SELECT 
    is_luxury_agents_kw,
    COUNT(*) AS agent_count,
    ROUND(AVG(average_price), 0) AS avg_price
FROM public.new_unified_agents
GROUP BY is_luxury_agents_kw;

Result :
| is_luxury_agents_kw | agent_count | avg_price |
| ------------------- | ----------- | --------- |
| false               | 143307      | 87264     |
| true                | 7277        | 122013    |
| null                | 926985      | 39509     |
