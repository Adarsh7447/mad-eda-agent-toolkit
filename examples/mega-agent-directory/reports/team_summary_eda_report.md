# Team Summary - Exploratory Data Analysis Report

## Table Overview
- **Table Name:** `public."Team_Summary"`
- **Total Records:** 98,376

---

## 1. Basic Data Profiling

### Total Record Count
| total_records |
|---------------|
| 98,376        |

### Sample Data Preview (10 Records)
| uuid | team_name | team_size_count | brokerage | state | city | source | size | fello_customer_status |
|------|-----------|-----------------|-----------|-------|------|--------|------|-----------------------|
| 786ccf3a-ffde-4690-8f3c-0a10370ccdcc | The Ion Group - brokered by REAL Broker, LLC | 5 | REAL Broker | null | Houston | Data_Maps_Teams | Small | Churned |
| 87781a39-6db1-4736-aef5-87aad686ce7f | Mark Salcido/ Keller Williams Property Team | 1 | Keller Williams | null | Gilroy | Data_Maps_Teams | Individual | Not a customer |
| 37d56701-f935-4252-9aa9-effcc11ca86a | Dan Johnson, REALTOR | 1 | Berkshire Hathaway | null | Montecito | Data_Maps_Teams | Individual | Not a customer |
| 17eb87fd-c1b1-46d2-b562-7f2424644a94 | Ari Keghinian with JohnHart Real Estate | 43 | JohnHart Real Estate | null | Burbank | Data_Maps_Teams | Mega | Not a customer |
| f610aabe-3e08-4b69-91ab-0dfecb3b02d5 | PMI Northbay | 1 | PMI Northbay | null | Fairfield | Data_Maps_Teams | Individual | Not a customer |
| 0fe283fa-3d11-49ed-80eb-60d1f9f6f24b | The Savard Group at Edina Realty | 2 | Edina Realty | null | Eagan | Data_Maps_Teams | Small | Not a customer |
| cf1fc88a-e4ac-439f-b2d5-1c263930e962 | Central Coast Real Estate | 2 | Central Coast Real Estate | null | Ventura | Data_Maps_Teams | Small | Not a customer |
| 36a81c76-bfc3-4108-9cc0-b7142f1eb5b7 | Boardwalk Realty & Management | 17 | Boardwalk Realty & Management | null | Draper | Data_Maps_Teams | Large | Not a customer |
| 432a1913-b2e9-46d8-a706-2aa97de1d01c | John Lewis - Broker/Owner of Realty Executives Temecula | 1 | Realty Executives Temecula | null | Temecula | Data_Maps_Teams | Individual | Not a customer |
| 5c7efa38-2964-4675-a4af-84928c12086e | Oregon Dreams Real Estate LLC | 3 | Oregon Dreams Real Estate LLC | null | N/A | Data_Maps_Teams | Small | Not a customer |

---

## 2. Missing Value Analysis

### Missing Value Counts
| total_rows | team_name_filled | team_name_missing | state_filled | state_missing | city_filled | city_missing | brokerage_filled | brokerage_missing | fello_status_filled | fello_status_missing | ai_website_filled | ai_website_missing | rank_2025_filled | rank_2025_missing |
|------------|------------------|-------------------|--------------|---------------|-------------|--------------|------------------|-------------------|---------------------|----------------------|-------------------|--------------------| -----------------|-------------------|
| 98,376     | 98,346           | 30                | 67,063       | 31,313        | 98,355      | 21           | 75,203           | 23,173            | 98,376              | 0                    | 47,844            | 50,532             | 3,966            | 94,410            |

### Missing Value Percentages
| Column | Null Percentage |
|--------|-----------------|
| team_name | 0.03% |
| state | 31.83% |
| city | 0.02% |
| team_size_count | 1.03% |
| sides | 95.38% |
| rank_2025 | 95.97% |

**Key Findings:**
- `fello_customer_status` has **0% missing** values
- `state` has significant missing data at **31.83%**
- `sides` and `rank_2025` have very high missing rates (>95%) - likely only populated for ranked teams

---

## 3. Categorical Distribution Analysis

### Distribution by State (Top 20)
| State | Team Count | Percentage |
|-------|------------|------------|
| CA | 7,163 | 10.68% |
| FL | 6,908 | 10.30% |
| TX | 5,403 | 8.06% |
| NC | 2,730 | 4.07% |
| NY | 2,483 | 3.70% |
| GA | 2,437 | 3.63% |
| IL | 1,862 | 2.78% |
| MI | 1,805 | 2.69% |
| CO | 1,646 | 2.45% |
| PA | 1,611 | 2.40% |
| VA | 1,411 | 2.10% |
| TN | 1,374 | 2.05% |
| AZ | 1,306 | 1.95% |
| SC | 1,291 | 1.93% |
| NJ | 1,289 | 1.92% |
| WA | 1,167 | 1.74% |
| OH | 1,138 | 1.70% |
| MA | 1,045 | 1.56% |
| MO | 1,002 | 1.49% |
| AL | 995 | 1.48% |

**Key Finding:** Top 3 states (CA, FL, TX) account for **29.04%** of all teams.

### Distribution by City (Top 20)
| City | State | Team Count |
|------|-------|------------|
| N/A | null | 2,598 |
| Miami | FL | 660 |
| Houston | TX | 578 |
| Chicago | IL | 483 |
| Austin | TX | 455 |
| Atlanta | GA | 330 |
| Orlando | FL | 309 |
| Washington | null | 301 |
| Las Vegas | null | 296 |
| Las Vegas | NV | 280 |
| Houston | null | 265 |
| San Francisco | null | 264 |
| Charlotte | NC | 260 |
| San Jose | null | 245 |
| Scottsdale | AZ | 244 |
| San Antonio | null | 238 |
| San Diego | CA | 235 |
| Denver | CO | 222 |
| San Diego | null | 217 |
| Philadelphia | PA | 214 |

**Note:** 2,598 records have "N/A" as city value. Some cities appear with both null and populated state values (data quality issue).

### Distribution by Source
| Source | Team Count | Percentage |
|--------|------------|------------|
| Data_Homes | 39,333 | 39.98% |
| Data_Maps_Teams | 30,879 | 31.39% |
| Data_KW | 12,711 | 12.92% |
| Data_Realtor | 4,986 | 5.07% |
| Data_Remax | 3,116 | 3.17% |
| wsj_real_trends_teams_medium | 2,897 | 2.94% |
| Data_BHHS | 2,279 | 2.32% |
| wsj_real_trends_teams_large | 1,096 | 1.11% |
| wsj_real_trends_teams_mega | 555 | 0.56% |
| Data_AT_Properties | 524 | 0.53% |

**Key Finding:** Top 2 sources (Data_Homes, Data_Maps_Teams) account for **71.37%** of all records.

### Distribution by Size Category
| Size | Team Count | Percentage |
|------|------------|------------|
| Individual | 43,754 | 44.48% |
| Small | 28,073 | 28.54% |
| Medium | 13,093 | 13.31% |
| Large | 7,421 | 7.54% |
| Mega | 6,035 | 6.13% |

**Key Finding:** **44.48%** of teams are categorized as "Individual" (single-person teams).

### Fello Customer Status Distribution
| Status | Team Count | Percentage |
|--------|------------|------------|
| Not a customer | 95,343 | 96.92% |
| Customer | 2,234 | 2.27% |
| Churned | 799 | 0.81% |

**Key Findings:**
- Only **2.27%** are current Fello customers
- **0.81%** have churned
- Massive potential market with **96.92%** non-customers

### Brokerage Distribution (Top 20)
| Brokerage | Team Count | Percentage |
|-----------|------------|------------|
| Keller Williams | 16,762 | 22.29% |
| RE/MAX | 5,365 | 7.13% |
| Berkshire Hathaway | 3,174 | 4.22% |
| Compass | 1,925 | 2.56% |
| eXp Realty | 1,815 | 2.41% |
| Coldwell Banker | 1,454 | 1.93% |
| CENTURY 21 | 656 | 0.87% |
| AT Properties | 524 | 0.70% |
| Sotheby's International Realty | 408 | 0.54% |
| NextHome | 296 | 0.39% |
| ERA Real Estate | 282 | 0.37% |
| LPT Realty | 241 | 0.32% |
| Real Broker, LLC | 221 | 0.29% |
| Better Homes | 202 | 0.27% |
| Howard Hanna | 195 | 0.26% |
| Windermere Real Estate | 195 | 0.26% |
| Real Broker | 157 | 0.21% |
| HomeSmart | 142 | 0.19% |
| DPI Realty Websites | 116 | 0.15% |
| Douglas Elliman | 110 | 0.15% |

**Key Finding:** **Keller Williams** dominates with **22.29%** of all teams.

---

## 4. Numerical Distribution Analysis

### Team Size Statistics
| Metric | Value |
|--------|-------|
| Minimum | 1 |
| Maximum | 16,000 |
| Average | 6.63 |
| Median | 2 |
| Standard Deviation | 61.08 |

**Key Finding:** Large gap between mean (6.63) and median (2) indicates **right-skewed distribution** with some very large teams.

### Sides Statistics
| Metric | Value |
|--------|-------|
| Minimum | 1 |
| Maximum | 10,279 |
| Average | 133.31 |
| Median | 86 |
| Standard Deviation | 258.78 |

### Rank 2025 Statistics
| Metric | Value |
|--------|-------|
| Minimum Rank | 1 |
| Maximum Rank | 2,350 |
| Distinct Ranks | 955 |

### Team Size Distribution Buckets
| Size Bucket | Team Count |
|-------------|------------|
| 1-5 | 72,812 |
| 6-10 | 11,292 |
| 11-25 | 8,710 |
| 26-50 | 3,391 |
| 51-100 | 874 |
| 100+ | 288 |

**Key Finding:** **74.88%** of teams have 5 or fewer members.

---

## 5. Cross-Tabulation Analysis

### Average Team Size by State (Top 15 States)
| State | Team Count | Avg Team Size | Avg Sides |
|-------|------------|---------------|-----------|
| CA | 7,163 | 5.06 | 283.31 |
| FL | 6,908 | 4.84 | 334.98 |
| TX | 5,403 | 5.82 | 370.18 |
| NC | 2,730 | 4.62 | 362.07 |
| NY | 2,483 | 5.51 | 218.33 |
| GA | 2,437 | 6.20 | 1,069.25 |
| IL | 1,862 | 6.15 | 264.63 |
| MI | 1,805 | 6.15 | 460.35 |
| CO | 1,646 | 4.08 | 291.04 |
| PA | 1,611 | 9.46 | 326.20 |
| VA | 1,411 | 6.55 | 447.24 |
| TN | 1,374 | 5.92 | 571.21 |
| AZ | 1,306 | 5.01 | 875.11 |
| SC | 1,291 | 5.73 | 406.19 |
| NJ | 1,289 | 7.48 | 349.08 |

**Key Findings:**
- **PA** has the highest average team size (9.46)
- **GA** has the highest average sides (1,069.25) - significant outlier
- **CO** has the smallest average team size (4.08) among top states

### Size Category vs Fello Customer Status
| Size | Status | Team Count |
|------|--------|------------|
| Individual | Not a customer | 43,422 |
| Individual | Customer | 224 |
| Individual | Churned | 108 |
| Large | Not a customer | 6,863 |
| Large | Customer | 422 |
| Large | Churned | 136 |
| Medium | Not a customer | 12,497 |
| Medium | Customer | 441 |
| Medium | Churned | 155 |
| Mega | Not a customer | 4,921 |
| Mega | Customer | 842 |
| Mega | Churned | 272 |
| Small | Not a customer | 27,640 |
| Small | Customer | 305 |
| Small | Churned | 128 |

**Customer Conversion Rate by Size:**
| Size | Customer Rate |
|------|---------------|
| Individual | 0.51% |
| Small | 1.09% |
| Medium | 3.37% |
| Large | 5.69% |
| Mega | 13.95% |

**Key Finding:** Larger teams have significantly higher customer conversion rates.

---

## 6. Website & Digital Presence Analysis

### Website Availability
| Website Status | Team Count | Percentage |
|----------------|------------|------------|
| No Website | 64,056 | 65.11% |
| Has Website | 34,320 | 34.89% |

### AI Website Detection
| AI Website Status | Team Count |
|-------------------|------------|
| No AI Website | 50,532 |
| AI Website Found | 47,844 |

### Serper Results
| Serper Status | Team Count |
|---------------|------------|
| Has Serper Results | 47,844 |
| No Serper Results | 50,532 |

**Key Finding:** Only **34.89%** of teams have a website recorded in the database.

---

## 7. Entity Analysis

### Entity Distribution
| Entity | Team Count | Percentage |
|--------|------------|------------|
| null | 82,172 | 83.53% |
| Market center KW | 12,711 | 12.92% |
| Brokerage Entity Remax | 3,116 | 3.17% |
| Office: BHHS | 313 | 0.32% |
| Office: AT Properties | 64 | 0.07% |

**Key Finding:** **83.53%** of records don't have an entity classification.

---

## 8. Key Insights Summary

### Data Quality Issues
1. **31.83%** of records missing state information
2. **95%+** missing for `sides` and `rank_2025` columns
3. City data inconsistencies (same city appearing with different state values)
4. 2,598 records with "N/A" as city value

### Business Insights
1. **Massive TAM (Total Addressable Market):** 96.92% are non-customers
2. **Keller Williams dominance:** 22.29% of all teams
3. **Geographic concentration:** CA, FL, TX account for ~29% of teams
4. **Size distribution:** 44.48% are individual agents/small operations
5. **Conversion opportunity:** Larger teams convert at higher rates (Mega: 13.95% vs Individual: 0.51%)
6. **Digital gap:** 65.11% of teams don't have a website recorded

### Recommendations
1. Focus sales efforts on **Mega** and **Large** teams for higher conversion rates
2. Prioritize **CA, FL, TX** for geographic expansion
3. Target **Keller Williams** teams as largest brokerage segment
4. Address data quality issues for `state` field
5. Consider website as a qualification criteria for outreach
