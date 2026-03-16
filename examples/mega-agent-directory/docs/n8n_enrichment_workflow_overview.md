# N8N Workflow Overview: Sub Workflow for Enrichment

## 📋 Executive Summary

This is a **sub-workflow** designed to enrich real estate agent data by scraping and processing information from **Zillow** profiles. It's triggered by another workflow and performs comprehensive data extraction, validation, and storage operations.

---

## 🎯 Workflow Purpose

**Primary Goal:** Enrich real estate agent records with detailed profile information from Zillow, including:
- Agent biographical information
- Sales statistics
- Contact details
- Social media profiles
- Ratings and reviews
- Brokerage information

---

## 🔄 Workflow Trigger

| Trigger Type | Description |
|--------------|-------------|
| **Execute Workflow Trigger** | Called by parent workflow with agent data |

### Expected Input Data
```json
{
  "list_name": "Agent Full Name",
  "list_company": "Company Name",
  "list_location": "City, State",
  "brokerage_name": "Brokerage Name",
  "id": "Database Record ID"
}
```

---

## 🏗️ Workflow Architecture

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           WORKFLOW START                                      │
│                    (When Executed by Another Workflow)                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHASE 1: ZILLOW URL DISCOVERY                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                   │
│  │ Perplexity   │───▶│ Code2        │───▶│ If4          │                   │
│  │ API Search   │    │ Extract URL  │    │ URL Found?   │                   │
│  └──────────────┘    └──────────────┘    └──────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
        ┌───────────────────┐           ┌───────────────────┐
        │ URL NOT FOUND     │           │ URL FOUND         │
        │ → Fallback Search │           │ → Direct Scrape   │
        └───────────────────┘           └───────────────────┘
                    │                               │
                    ▼                               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHASE 2: ZILLOW PROFILE SCRAPING                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                   │
│  │ ScraperAPI   │───▶│ HTML Parser  │───▶│ HTML8        │                   │
│  │ (Premium)    │    │ Extract Body │    │ CSS Selectors│                   │
│  └──────────────┘    └──────────────┘    └──────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHASE 3: AI DATA EXTRACTION                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                   │
│  │ Data         │───▶│ Expanded     │───▶│ Bio-Details  │                   │
│  │ Organiser    │    │ Get To Know  │    │ LLM Chain    │                   │
│  │ (Gemini)     │    │ Me Parser    │    │ (Gemini)     │                   │
│  └──────────────┘    └──────────────┘    └──────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHASE 4: DATA STORAGE                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                   │
│  │ Supabase     │    │ Google       │    │ Lead         │                   │
│  │ Update       │    │ Sheets       │    │ Validation   │                   │
│  └──────────────┘    └──────────────┘    └──────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Key Components

### 1. External APIs Used

| API | Purpose | Credentials |
|-----|---------|-------------|
| **Perplexity AI** | Zillow URL discovery via web search | `` |
| **ScraperAPI** | Web scraping with JS rendering | `` |
| **Google Gemini** | Data extraction & organization | Google PaLM API |
| **OpenAI GPT-4o-mini** | Lead validation scoring | OpenAI API |
| **Anthropic Claude** | Information extraction | Anthropic API |

### 2. Data Storage

| Storage | Purpose |
|---------|---------|
| **Supabase** | Primary database (`agents_2` table) |
| **Google Sheets** | Secondary storage & reporting |

### 3. AI Models Used

| Model | Node | Purpose |
|-------|------|---------|
| `gemini-2.0-flash` | Data Organiser, Bio-Details | Extract structured data from HTML |
| `gpt-4o-mini` | Lead Validation Agent | Calculate confidence scores |
| `claude-sonnet-4` | Information Extractor | Extract agent info from search results |
| `sonar-reasoning-pro` | Perplexity | Web search for Zillow URLs |

---

## 📊 Data Extraction Schema

### Agent Basic Info (Data Organiser)
```json
{
  "agentName": [],
  "agentdesignation": [],
  "teamName": [],
  "salesInfo": {
    "salesLast12Months": [],
    "totalSales": [],
    "priceRange": [],
    "averagePrice": []
  },
  "emails": [],
  "phoneNumbers": [],
  "address": [],
  "googleaddresslink": [],
  "imageUrl": []
}
```

### Agent Bio & Social (Bio-Details)
```json
{
  "AgentBio": [],
  "AgentWebsite": [],
  "SocialMedia": {
    "linkedin": [],
    "facebook": [],
    "instagram": [],
    "twitter": [],
    "youtube": [],
    "tiktok": [],
    "others": []
  }
}
```

### Lead Validation Output
```json
{
  "score": "Confidence Score in %",
  "reason": "Explanation detailing field comparisons"
}
```

---

## 🔀 Workflow Branches

### Branch 1: Direct Zillow URL (Perplexity Found URL)
```
HTTP Request2 → Code2 → If4 (URL Found) → HTTP Request1 → HTML → HTML8 → Data Organiser → Bio-Details → Supabase
```

### Branch 2: Fallback Search (URL Not Found)
```
If4 (No URL) → HTTP Request9 → HTML4 → HTML12 → Markdown → Information Extractor → HTTP Request7 → Code4 → HTTP Request6 → HTML → ...
```

### Branch 3: Error Handling (Axios Errors)
```
If1/If9/If10 (AxiosError) → Wait → Retry HTTP Request
```

---

## 📝 CSS Selectors Used for Zillow Scraping

| Data Point | CSS Selector |
|------------|--------------|
| Agent Name | `#__next > div > div... > h1` |
| Agent Details | `#__next > div > div... > div.ttNyW > div` |
| Agent Bio | `#get-to-know-me > div > div... > div` |
| Website | `#get-to-know-me > div > div... > a` |
| Zillow Reviews | `#__next > div > div... > div.gCVCCJ` |
| Top Agent Details | `#__next > div > div.cWMiTu > div:nth-child(3)...` |

---

## 🎯 Lead Validation Scoring

### Scoring Criteria
| Factor | Max Points | Description |
|--------|------------|-------------|
| Name Match | 18 | Full or partial name match |
| Email Match | 29 | Exact match or similar structure |
| Phone Number Match | 24 | Full or partial match |
| Website Match | 18 | Matching domains or branding |
| Other Clues | 11 | Social links, location, brokerage |

**Total: 100 points** (normalized based on available fields)

---

## 💾 Database Schema (Supabase - agents_2)

| Field | Source |
|-------|--------|
| `full_name_zw` | Data Organiser |
| `agent_designation_zw` | Data Organiser |
| `about_agent_zw` | Bio-Details |
| `team_name_zw` | Data Organiser |
| `brokerage_name` | Input Data |
| `sales_last_12_months_zw` | Data Organiser |
| `total_sales_zw` | Data Organiser |
| `price_range_zw` | Data Organiser |
| `average_price_zw` | Data Organiser |
| `agent_email_zw` | Data Organiser |
| `agent_phone_numbers_zw` | Data Organiser |
| `agent_address_zw` | Data Organiser |
| `zillow_profile_url_zw` | Code2/Code4 |
| `website_zw` | Bio-Details |
| `linkedin_url_zw` | Bio-Details |
| `facebook_url_zw` | Bio-Details |
| `instagram_url_zw` | Bio-Details |
| `twitter_url_zw` | Bio-Details |
| `youtube_url_zw` | Bio-Details |
| `tiktok_url_zw` | Bio-Details |
| `Zillow_Review` | Reviews |
| `Zillow_review_count` | Reviews |
| `created_at` | Date & Time |
| `updated_at` | Date & Time |

---

## ⚠️ Error Handling

### Retry Logic
- **HTTP Requests**: Max 5 retries with `retryOnFail: true`
- **Axios Errors**: Detected and routed to Wait nodes for retry
- **Continue on Error**: Most nodes have `onError: "continueRegularOutput"`

### Wait Nodes
| Node | Duration | Purpose |
|------|----------|---------|
| Wait | 1 second | Retry after scraping failure |
| Wait2 | 1 second | Retry after search failure |
| Wait4/5/6 | Default | Throttle lead validation |

---

## 📈 Workflow Statistics

| Metric | Value |
|--------|-------|
| Total Nodes | 58 |
| HTTP Request Nodes | 10 |
| AI/LLM Nodes | 8 |
| Conditional (If) Nodes | 8 |
| Code Nodes | 6 |
| Storage Nodes | 7 |

---

## 🔐 Security Notes

⚠️ **API Keys Exposed in Workflow:**
- ScraperAPI: ``
- Perplexity: ``

**Recommendation:** Move API keys to n8n credentials store or environment variables.

---

## 🚀 Usage

### Triggering the Workflow
This workflow is called by a parent workflow using the **Execute Workflow** node with the following data:

```json
{
  "list_name": "John Smith",
  "list_company": "ABC Realty",
  "list_location": "Miami, FL",
  "brokerage_name": "Keller Williams",
  "id": "12345"
}
```

### Expected Output
- Updated Supabase record with enriched agent data
- Updated Google Sheets row with agent details
- Lead validation score and reasoning

---

## 📋 Workflow Diagram Legend

```
┌──────────┐   HTTP Request / API Call
└──────────┘

┌──────────┐   Data Transformation / Code
└──────────┘

┌──────────┐   AI/LLM Processing
└──────────┘

┌──────────┐   Conditional Logic
└──────────┘

┌──────────┐   Data Storage
└──────────┘
```
