# New Unified Agents - Exploratory Data Analysis Report

## Table Overview
- **Table Name:** `public.new_unified_agents`
- **Total Records:** 1,077,569
- **Data Period:** Feb 17, 2026 - Mar 12, 2026

---

## 1. Basic Data Profiling

### Total Record Count
| total_agents |
|--------------|
| 1,077,569    |

### Date Range of Updates
| earliest_update | latest_update |
|-----------------|---------------|
| 2026-02-17 15:58:34 | 2026-03-12 06:39:36 |

---

## 2. Missing Value Analysis

### Missing Value Counts
| Field | Filled Count | Missing Count | Missing % |
|-------|--------------|---------------|-----------|
| full_name | 1,077,567 | 2 | 0.00% |
| email | 923,803 | 153,766 | 14.27% |
| phone | 796,297 | 281,272 | 26.10% |
| state | 744,346 | 333,223 | 30.92% |
| team_id | 585,882 | 491,687 | 45.63% |
| brokerage_name | 530,470 | 547,099 | 50.77% |
| experience_years | 529,331 | 548,238 | 50.87% |
| CRM | 127,886 | 949,683 | 88.13% |

**Key Findings:**
- **full_name** has near-complete data (only 2 missing)
- **CRM** has the highest missing rate at **88.13%**
- About **50%** of records are missing brokerage and experience data
- **26.10%** missing phone numbers, **14.27%** missing emails

---

## 3. Geographic Distribution

### Distribution by State (Top 20)
| State | Agent Count | Percentage |
|-------|-------------|------------|
| FL | 99,334 | 13.20% |
| CA | 78,580 | 10.44% |
| TX | 60,759 | 8.07% |
| NY | 29,425 | 3.91% |
| GA | 28,097 | 3.73% |
| IL | 25,038 | 3.33% |
| NC | 24,313 | 3.23% |
| PA | 23,395 | 3.11% |
| AZ | 21,985 | 2.92% |
| OH | 20,388 | 2.71% |
| MI | 18,504 | 2.46% |
| VA | 16,931 | 2.25% |
| TN | 16,411 | 2.18% |
| CO | 14,633 | 1.94% |
| NJ | 13,502 | 1.79% |
| MO | 12,788 | 1.70% |
| SC | 12,745 | 1.69% |
| MD | 12,180 | 1.62% |
| WA | 12,090 | 1.61% |
| MN | 10,268 | 1.36% |

**Key Finding:** Top 3 states (FL, CA, TX) account for **31.71%** of all agents.

### Distribution by City (Top 20)
| City | Agent Count |
|------|-------------|
| N/A | 9,727 |
| Houston | 8,853 |
| Chicago | 6,693 |
| Atlanta | 6,422 |
| Austin | 6,192 |
| New York | 5,747 |
| San Antonio | 5,691 |
| Denver | 4,915 |
| Miami | 4,769 |
| Scottsdale | 4,599 |
| Las Vegas | 4,486 |
| Dallas | 4,481 |
| Charlotte | 3,993 |
| San Diego | 3,824 |
| Jacksonville | 3,821 |
| Philadelphia | 3,755 |
| Orlando | 3,672 |
| Tampa | 3,488 |
| Portland | 3,362 |
| Nashville | 3,308 |

**Note:** 9,727 records have "N/A" as city value (data quality issue).

---

## 4. Team Analysis

### Team vs Individual Agents
| Agent Type | Agent Count | Percentage |
|------------|-------------|------------|
| Individual | 491,687 | 45.63% |
| Team Member | 585,882 | 54.37% |

**Key Finding:** Majority (**54.37%**) of agents are part of a team.

### Team Size Distribution
| Team Size | Agent Count | Percentage |
|-----------|-------------|------------|
| Individual | 157,577 | 35.69% |
| Unknown | 140,048 | 31.72% |
| Mega | 52,250 | 11.83% |
| Small | 38,743 | 8.78% |
| Large | 29,492 | 6.68% |
| Medium | 23,174 | 5.25% |
| Other (numeric) | ~220 | 0.05% |

### Team Size Statistics
| Metric | Value |
|--------|-------|
| Minimum | -2 |
| Maximum | 500,000 |
| Average | 492.93 |
| Median | 1 |

**Key Finding:** Large gap between mean (492.93) and median (1) indicates extreme outliers in team size data.

### Zillow Team Status
| Status | Agent Count |
|--------|-------------|
| null | 1,067,240 |
| NA | 9,356 |
| Team | 973 |

---

## 5. Brokerage Analysis

### Top Brokerages by Agent Count
| Brokerage | Agent Count | Percentage |
|-----------|-------------|------------|
| NA | 67,181 | 12.66% |
| Keller Williams | 13,499 | 2.54% |
| Keller Williams Realty | 10,262 | 1.93% |
| Compass | 9,693 | 1.83% |
| eXp Realty | 9,304 | 1.75% |
| RE/MAX | 4,822 | 0.91% |
| Coldwell Banker | 4,352 | 0.82% |
| Berkshire Hathaway HomeServices California Properties | 2,505 | 0.47% |
| Coldwell Banker Realty | 2,284 | 0.43% |
| @properties Christie's International Real Estate | 2,253 | 0.42% |
| JohnHart Real Estate | 1,873 | 0.35% |
| Berkshire Hathaway HomeServices | 1,727 | 0.33% |
| LPT Realty | 1,510 | 0.28% |
| Berkshire Hathaway HomeServices The Preferred Realty | 1,242 | 0.23% |
| RE/MAX Results | 1,236 | 0.23% |
| Better Homes and Gardens Real Estate | 1,159 | 0.22% |
| Weichert, Realtors® | 1,142 | 0.22% |
| Berkshire Hathaway HomeServices Georgia Properties | 1,092 | 0.21% |
| BHHS Fox & Roach | 982 | 0.19% |
| Berkshire Hathaway HomeServices New England Properties | 922 | 0.17% |

### Brokerage Main (Normalized) - Top 20
| Brokerage | Agent Count |
|-----------|-------------|
| Keller Williams | 79,377 |
| RE/MAX | 39,794 |
| Berkshire Hathaway | 32,754 |
| eXp Realty | 12,666 |
| Compass | 10,801 |
| Coldwell Banker | 10,712 |
| CENTURY 21 | 5,614 |
| @properties | 3,684 |
| Better Homes | 3,305 |
| Sotheby's International Realty | 2,977 |
| NextHome | 2,028 |
| LPT Realty | 1,929 |
| JohnHart Real Estate | 1,873 |
| Howard Hanna | 1,849 |
| ERA Real Estate | 1,643 |
| Windermere Real Estate | 1,269 |
| Weichert, Realtors® | 1,142 |
| HomeSmart | 974 |
| Real Broker, LLC | 914 |
| Homesnap | 909 |

**Key Finding:** **Keller Williams** dominates with 79,377 agents (normalized brokerage name).

---

## 6. CRM & Marketing Tools Analysis

### CRM Distribution (Top 20)
| CRM | Agent Count | Percentage |
|-----|-------------|------------|
| [] (Empty) | 63,327 | 49.52% |
| ["Inside Real Estate", "KVCore"] | 8,961 | 7.01% |
| ["Agent Image", "Inside Real Estate", "KVCore"] | 5,525 | 4.32% |
| ["Spark Platform"] | 3,946 | 3.09% |
| ["Lofty (Chime)"] | 3,494 | 2.73% |
| ["MoxiWorks"] | 2,992 | 2.34% |
| ["iHouseWeb"] | 2,645 | 2.07% |
| (blank) | 2,307 | 1.80% |
| ["IDXBroker"] | 2,300 | 1.80% |
| ["iHomefinder"] | 2,025 | 1.58% |
| ["WordPress"] | 1,695 | 1.33% |
| ["Real Geeks"] | 1,657 | 1.30% |
| ["Agent Image", "iHomefinder"] | 1,378 | 1.08% |
| ["MoxiWorks", "RealScout"] | 1,336 | 1.04% |
| ["Follow Up Boss"] | 1,100 | 0.86% |
| ["Sierra Interactive"] | 1,051 | 0.82% |
| ["Agent Image"] | 999 | 0.78% |
| ["Brivity"] | 841 | 0.66% |
| ["Boomtown ROI"] | 838 | 0.66% |
| ["LiveBy"] | 834 | 0.65% |

### Top CRMs (Unnested)
| CRM | Usage Count |
|-----|-------------|
| KVCore | 22,919 |
| Inside Real Estate | 17,093 |
| KVCore (variant) | 16,380 |
| Spark Platform | 11,453 |
| Agent Image | 9,582 |
| Inside Real Estate (variant) | 8,668 |
| iHomefinder | 7,911 |
| MoxiWorks | 6,932 |
| Follow Up Boss | 5,734 |
| IDXBroker | 5,116 |
| Brivity | 4,933 |
| Lofty (Chime) | 3,881 |

**Key Finding:** **KVCore** and **Inside Real Estate** are the most popular CRMs.

### Top Marketing Tools
| Marketing Tool | Usage Count |
|----------------|-------------|
| WordPress | 46,897 |
| WordPress (variant) | 30,396 |
| Google Analytics | 28,638 |
| Google Analytics 4 | 24,487 |
| Global Site Tag | 20,337 |
| Facebook Pixel | 14,287 |
| Google Universal Analytics | 14,044 |
| ListTrac | 13,920 |
| LiveBy | 11,201 |
| Google AdWords Conversion | 11,189 |
| Percy AI | 9,140 |
| WordPress 6.8 | 8,945 |
| Atlassian Cloud | 8,320 |
| Facebook Conversion Tracking | 8,061 |
| Luxury Presence | 7,749 |

---

## 7. Experience & Performance Analysis

### Experience Years Distribution
| Experience Bucket | Agent Count | Avg Total Sales |
|-------------------|-------------|-----------------|
| 0-2 years | 48,658 | 13 |
| 3-5 years | 69,256 | 89,509 |
| 6-10 years | 101,541 | 70 |
| 11-20 years | 138,427 | 85 |
| 20+ years | 171,449 | 96 |

### Experience Statistics
| Metric | Value |
|--------|-------|
| Minimum | 0 |
| Maximum | 4,020 |
| Average | 377.15 |
| Median | 15 |

**Note:** Max experience of 4,020 years indicates data quality issues.

### Total Sales Statistics
| Metric | Value |
|--------|-------|
| Minimum | 0 |
| Maximum | 3,817,200,121 |
| Average | 15,011 |
| Median | 35 |

### Average Price Statistics
| Metric | Value |
|--------|-------|
| Minimum | $0 |
| Maximum | $49,000,000 |
| Average | $40,409.24 |
| Median | $306.20 |

### Experience vs Performance
| Experience Bucket | Agent Count | Avg Price | Avg Sales |
|-------------------|-------------|-----------|-----------|
| 0-5 years | 117,914 | $2,598 | 54,717 |
| 6-10 years | 101,541 | $3,774 | 70 |
| 11-20 years | 138,427 | $5,062 | 85 |
| 20+ years | 171,449 | $13,580 | 96 |

**Key Finding:** Average price increases with experience, but sales data shows inconsistencies.

---

## 8. Ratings & Reviews Analysis

### Zillow Ratings Distribution
| Rating Bucket | Agent Count | Avg Review Count |
|---------------|-------------|------------------|
| 4.5-5.0 | 12,054 | 30 |
| 4.0-4.4 | 85 | 6 |
| 3.0-3.9 | 55 | 3 |
| Below 3.0 | 3,366 | -1 |

### Platform Rating Comparison
| Platform | Avg Rating | Avg Reviews |
|----------|------------|-------------|
| Zillow | 3.69 | 23 |
| Google | 2.85 | 40 |
| Realtor | 0.88 | 2 |

### Top Rated Agents (Min 10 Reviews)
| Agent Name | Zillow Rating | Reviews | Top Agent | Brokerage |
|------------|---------------|---------|-----------|-----------|
| Michael Tyszka | 5.0 | 994 | Top Agent | Keller Williams Realty Cherry Hill |
| Jennifer Landro | 5.0 | 987 | Top Agent | NA |
| Treasure Davis | 5.0 | 975 | Top Agent | eXp Realty |
| Jen Marie | 5.0 | 974 | Top Agent | NA |
| Andy Bovender | 5.0 | 974 | NA | Compass |
| Ron Howard | 5.0 | 971 | Top Agent | RE/MAX Advantage Realty |
| Kirby Scofield | 5.0 | 956 | Top Agent | LPT Realty |
| Scot Brothers | 5.0 | 943 | Top Agent | eXp Realty |
| Bob And Ronna | 5.0 | 940 | Top Agent | Samson Properties |
| Brett Sikora | 5.0 | 939 | Top Agent | NA |

---

## 9. Premium Status Analysis

### Zillow Premium Distribution
| Status | Agent Count | Percentage |
|--------|-------------|------------|
| null | 1,057,773 | 98.16% |
| NA | 9,733 | 0.90% |
| no | 9,386 | 0.87% |
| Premier | 571 | 0.05% |
| yes | 106 | 0.01% |

### Realtor Premium Distribution
| Status | Agent Count | Percentage |
|--------|-------------|------------|
| null | 976,780 | 90.65% |
| NA | 97,705 | 9.07% |
| (blank) | 2,581 | 0.24% |
| Premium | 503 | 0.05% |

### Zillow Top Agent Distribution
| Status | Agent Count |
|--------|-------------|
| null | 1,067,240 |
| NA | 6,733 |
| Top Agent | 3,596 |

**Key Finding:** Only **0.05%** have Premier status on Zillow, and **3,596** are designated as Top Agents.

---

## 10. Social Media Presence Analysis

### Social Media Availability
| Platform | Has Profile | Percentage |
|----------|-------------|------------|
| Facebook | 330,444 | 30.67% |
| LinkedIn | 200,756 | 18.63% |
| Instagram | 153,417 | 14.24% |
| YouTube | 48,685 | 4.52% |
| Twitter | 41,659 | 3.87% |
| TikTok | 19,088 | 1.77% |

### Social Score Distribution
| Score Bucket | Agent Count |
|--------------|-------------|
| No Score | 954,284 |
| Low (1-25) | 123,285 |

### Social Label Distribution
| Label | Agent Count |
|-------|-------------|
| poor | 55,122 |
| good | 45,099 |
| medium | 44,564 |
| none | 9 |
| low | 3 |
| no socials found | 2 |

**Key Finding:** **Facebook** is the most common social platform (30.67%), while **TikTok** adoption is lowest (1.77%).

---

## 11. Fello Customer Analysis

### Fello Customer Status Distribution
| Status | Agent Count | Percentage |
|--------|-------------|------------|
| null | 1,061,613 | 98.52% |
| Customer | 11,276 | 1.05% |
| Churned | 4,401 | 0.41% |
| Churn | 279 | 0.03% |

### Fello Customer Status (Main Array)
| Status | Agent Count |
|--------|-------------|
| Customer | 12,147 |
| Churned | 4,401 |
| Churn | 279 |

### Fello Linkage
| Status | Count |
|--------|-------|
| Linked to Fello | 15,956 |
| Not Linked | 1,061,613 |
| **Total** | 1,077,569 |

**Key Findings:**
- Only **1.05%** are current Fello customers
- **0.41%** have churned
- **15,956** agents are linked to Fello customer records
- Massive potential market with **98.52%** non-customers

---

## 12. Source Analysis

### Data Source Distribution
| Source | Agent Count |
|--------|-------------|
| Data_Realtor | 308,802 |
| Data_Homes | 234,982 |
| Data_Maps | 221,214 |
| Data_KW | 112,412 |
| Company_Info | 52,648 |
| Data_Remax | 46,334 |
| Data_BHHS | 43,952 |
| Data_OneReal | 27,050 |
| Data_BetterHomes | 10,093 |
| agents_1 | 8,704 |
| agents_duplicate_confidence_table | 6,663 |
| agents_3 | 6,362 |
| agents_2 | 5,801 |
| Data_AT_Properties | 4,591 |
| Data_Epique | 3,888 |
| agents_3_duplicate_confidence_table | 3,764 |
| agents_2_duplicate_confidence_table | 1,510 |

### Agents by Source Count
| Source Count | Agent Count |
|--------------|-------------|
| 0 | 1,123 |
| 1 | 1,054,730 |
| 2 | 21,123 |
| 3 | 578 |
| 4 | 15 |

**Key Finding:** **Data_Realtor** is the largest data source with 308,802 agents.

---

## 13. Data Quality Checks

### Duplicate Full Names (Top 20)
| Full Name | Occurrences |
|-----------|-------------|
| Hilary Saunders | 151 |
| Na | 109 |
| Frank Martell | 94 |
| Josh McCarter | 94 |
| Ori Allon | 94 |
| Steven Sordello | 94 |
| Dawanna Williams | 94 |
| Allan Leinwand | 94 |
| Pamela Thomas-Graham | 94 |
| Robert Reffkin | 94 |
| Scott Wahlers | 90 |
| Rory Golod | 90 |
| Neda Navab | 90 |
| Richard "Ric" Martel, Jr. | 82 |
| The Group | 78 |
| Michael Smith | 60 |
| Deborah Penny | 60 |
| (blank) | 59 |
| Larry Knapp | 59 |
| Dave Wetzel | 58 |

**Note:** High occurrences for names like "Robert Reffkin" (Compass CEO) suggest data duplication from company info pages.

### Website Availability
| Status | Agent Count |
|--------|-------------|
| Has Website | 392,982 |
| No Website | 684,587 |

**Key Finding:** **36.47%** of agents have a website recorded.

### Review Status Distribution
| Status | Agent Count |
|--------|-------------|
| null | 1,072,977 |
| updated | 2,581 |
| update | 1,981 |
| new_delete | 29 |
| (blank) | 1 |

### Primary Contact Analysis
| Is Primary Contact | Agent Count |
|--------------------|-------------|
| true | 32,329 |
| null | 1,045,240 |

### Luxury Agents (KW)
| Is Luxury Agent | Agent Count | Avg Price |
|-----------------|-------------|-----------|
| false | 143,307 | $87,264 |
| true | 7,277 | $122,013 |
| null | 926,985 | $39,509 |

---

## 14. Cross-Tabulation: Team Size vs Fello Status

| Team Size | Not Customer | Customer | Churned | Churn |
|-----------|--------------|----------|---------|-------|
| Individual | 154,922 | 1,854 | 751 | 50 |
| Unknown | 137,996 | 1,439 | 589 | 24 |
| Mega | 51,017 | 910 | 313 | 10 |
| Small | 37,800 | 648 | 264 | 31 |
| Large | 28,436 | 825 | 213 | 18 |
| Medium | 22,538 | 448 | 176 | 12 |

**Customer Conversion Rate by Team Size:**
| Team Size | Customer Rate |
|-----------|---------------|
| Individual | 1.18% |
| Small | 1.67% |
| Medium | 1.93% |
| Large | 2.80% |
| Mega | 1.74% |
| Unknown | 1.03% |

---

## 15. Key Insights Summary

### Data Quality Issues
1. **Experience years** has max value of 4,020 (impossible)
2. **Team size count** has max value of 500,000 (outlier)
3. **Duplicate names** for company executives (Robert Reffkin appears 94 times)
4. **30.92%** missing state information
5. **88.13%** missing CRM data

### Business Insights
1. **Massive TAM:** 98.52% are non-Fello customers (1,061,613 agents)
2. **Geographic concentration:** FL, CA, TX account for 31.71% of agents
3. **Brokerage dominance:** Keller Williams leads with 79,377 agents
4. **Team structure:** 54.37% are team members vs 45.63% individual
5. **Digital presence:** Only 36.47% have a website recorded
6. **Social media:** Facebook most common (30.67%), TikTok lowest (1.77%)
7. **Premium status:** Very low (0.05% Zillow Premier, 0.05% Realtor Premium)
8. **Top CRMs:** KVCore and Inside Real Estate dominate

### Recommendations
1. **Data Quality:** Clean experience_years and team_size_count outliers
2. **Deduplication:** Address duplicate records from company info scraping
3. **Enrichment:** Fill missing state (30.92%) and brokerage (50.77%) data
4. **Sales Focus:** Target Large teams (2.80% conversion rate)
5. **Geographic Focus:** Prioritize FL, CA, TX markets
6. **Brokerage Partnerships:** Focus on Keller Williams agents

---

## Appendix: SQL Queries Reference

All queries used in this analysis are available in:
`/Users/adarshbadjate/code/EDA/eda_queries/new_unified_agents_eda.sql`
