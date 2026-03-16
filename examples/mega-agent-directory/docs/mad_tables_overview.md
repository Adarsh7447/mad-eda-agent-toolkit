# MAD Database Tables Overview

This document describes the tables used in the MAD database and their purpose.

---

# 1. Core API Tables

These tables are used directly by the MAD UI through the PostgREST API.

| Table Name | Description |
|------------|-------------|
| `new_unified_agents` | Primary unified dataset of agents. Data is fetched via PostgREST API and acts as the main source for MAD. |
| `Team_Summary` | Contains summarized information about real estate teams used in MAD. |
| `mad_dashboard` | Stores aggregated metrics used for displaying counts and statistics on the MAD dashboard landing page. |

---

# 2. Customer Related Tables

Tables related to Fello customers and churn tracking.

| Table Name | Description |
|------------|-------------|
| `Current_Customer_Master_List` | Master list of Fello customers. |
| `Fello_Customer_Status` | Tracks whether a customer is active or churned. |
| `Fello_Customer_Churn_Status` | Tracks churned customers. |

---

# 3. Company Information Tables

Tables related to company-level metadata and team member extraction.

| Table Name | Description |
|------------|-------------|
| `company_info` | Raw company information table containing nested JSON data for team members. |
| `Company Info Team Members` | Unnested version of team member data extracted from `company_info`. |
| `agent_info_ci` | Helper table used to unnest JSON data from `company_info`. |

---

# 4. Real Trends Teams Data

Tables containing team rankings sourced from Real Trends / WSJ datasets.

| Table Name | Description |
|------------|-------------|
| `wsj_real_trends_teams_small` | Real Trends small teams dataset. |
| `wsj_real_trends_teams_medium` | Real Trends medium teams dataset. |
| `wsj_real_trends_teams_large` | Real Trends large teams dataset. |
| `wsj_real_trends_teams_mega` | Real Trends mega teams dataset. |

---

# 5. Agent Data (Real Trends)

Datasets containing agents belonging to Real Trends teams.

| Table Name | Description |
|------------|-------------|
| `agents` | Base dataset of agents belonging to Real Trends teams. |
| `agents_2` | Additional batch of Real Trends agents. |
| `agents_3` | Additional batch of Real Trends agents. |
| `agents_4` | Additional batch of Real Trends agents. |
| `agents_4_hemanth` | Experimental dataset of Real Trends agents. |

---

# 6. Duplicate Detection Tables

Tables used to track duplicate confidence scores across agent datasets.

| Table Name | Description |
|------------|-------------|
| `agents_duplicate_confidence_table` | Duplicate confidence scores for `agents`. |
| `agents_2_duplicate_confidence_table` | Duplicate confidence scores for `agents_2`. |
| `agents_3_duplicate_confidence_table` | Duplicate confidence scores for `agents_3`. |
| `agents_4_duplicate_confidence_table` | Duplicate confidence scores for `agents_4`. |
| `only_agents_1_duplicate` | Duplicate confidence scores for `only_agents_1`. |

---

# 7. Individual Agent Datasets

Tables containing individual real estate agents enriched using Zillow data.

| Table Name | Description |
|------------|-------------|
| `only_agents_1` | Individual agents enriched from Zillow dataset batch 1. |
| `only_agents_2` | Individual agents enriched from Zillow dataset batch 2. |
| `only_agents_3` | Individual agents enriched from Zillow dataset batch 3. |
| `only_agents_4` | Individual agents enriched from Zillow dataset batch 4. |
| `only_agents_5` | Individual agents enriched from Zillow dataset batch 5. |
| `only_agents_6` | Individual agents enriched from Zillow dataset batch 6. |

---

# 8. Purchased / Scraped Data Sources

Tables containing data purchased or scraped from real estate websites.

| Table Name | Description |
|------------|-------------|
| `Data_AT_Properties` | Data sourced from AT Properties. |
| `Data_BHHS` | Data sourced from Berkshire Hathaway HomeServices. |
| `Data_BetterHomes` | Data sourced from Better Homes and Gardens Real Estate. |
| `Data_Epique` | Data sourced from Epique Realty. |
| `Data_Homes` | Data sourced from Homes.com. |
| `Data_KW` | Data sourced from Keller Williams. |
| `Data_OneReal` | Data sourced from One Real Estate network. |
| `Data_Realtor` | Data sourced from Realtor.com. |
| `Data_Remax` | Data sourced from RE/MAX listings. |

Note:  
The **`source` column in `new_unified_agents`** indicates which dataset the record originated from.

---

# 9. Google Maps Scraped Data

Tables containing teams and agents scraped from Google Maps.

| Table Name | Description |
|------------|-------------|
| `Data_maps_teams` | Real estate teams scraped from Google Maps. |
| `agents_maps` | Agents belonging to teams scraped from Google Maps. |

---

# 10. Internal Mapping Tables

Internal tables used for data transformation or mapping.

| Table Name | Description |
|------------|-------------|
| `Team_Summary_1` | Internal mapping table used for datasets such as RE/MAX. |
| `Team_Summary_2` | Internal mapping table used for datasets such as RE/MAX. |

---

# Notes

- All tables exist in the **`public` schema**.
- Database owner: **postgres**.
- Some tables act as **intermediate datasets used during data ingestion, enrichment, or deduplication pipelines**.
- `new_unified_agents` acts as the **primary unified dataset used by MAD APIs**.
