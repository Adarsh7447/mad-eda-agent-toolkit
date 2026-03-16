create table public.agents_3_duplicate_confidence_table (
  id text not null,
  list_name text null,
  list_company text null,
  list_location text null,
  full_name_zw text null,
  agent_designation_zw text null,
  team_name_zw text null,
  about_agent_zw text null,
  agent_address_zw text null,
  address_url_zw text null,
  agent_email_zw text null,
  personal_email text null,
  agent_phone_numbers_zw text null,
  zillow_profile_url_zw text null,
  sales_last_12_months_zw smallint null,
  total_sales_zw integer null,
  average_price_zw integer null,
  price_range_zw text null,
  website_zw text null,
  linkedin_url_zw text null,
  facebook_url_zw text null,
  instagram_url_zw text null,
  twitter_url_zw text null,
  youtube_url_zw text null,
  tiktok_url_zw text null,
  other_socials_zw text null,
  brokerage_name text null,
  transaction_zipcodes text null,
  license_id text null,
  industry text null,
  fello_customer_status text null,
  date_of_churn date null,
  is_marketing_contact boolean null,
  created_at timestamp with time zone null,
  updated_at timestamp with time zone null,
  team_id uuid null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_phone text null,
  normalized_license_number text null,
  deduplication_key text null,
  "Name match" text null,
  "Company-Team match" text null,
  "Company-Designation match" text null,
  "Company-Website match" text null,
  "Company-Email match" text null,
  "Brokerage-Team match" text null,
  "Brokerage-Designation match" text null,
  "Brokerage-Website match" text null,
  "Brokerage-Email match" text null,
  "Match Verdict" text null,
  aryan_600_teams_agents text null,
  zillow_pro_or_not text null,
  "Zillow_Review" real null,
  "Zillow_review_count" smallint null,
  constraint agents_3_duplicate_confidence_table_pkey primary key (id)
) TABLESPACE pg_default;

create index IF not exists agents_3_duplicate_confidence_table_deduplication_key_idx on public.agents_3_duplicate_confidence_table using btree (deduplication_key) TABLESPACE pg_default;

create index IF not exists agents_3_duplicate_confidence_table_normalized_full_name_idx on public.agents_3_duplicate_confidence_table using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_a3_name on public.agents_3_duplicate_confidence_table using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_a3_email on public.agents_3_duplicate_confidence_table using btree (normalized_email) TABLESPACE pg_default;

create index IF not exists idx_a3_phone on public.agents_3_duplicate_confidence_table using btree (normalized_phone) TABLESPACE pg_default;

create index IF not exists agents_3_duplicate_confidence_table_normalized_email_idx on public.agents_3_duplicate_confidence_table using btree (normalized_email) TABLESPACE pg_default;

create index IF not exists agents_3_duplicate_confidence_table_normalized_phone_idx on public.agents_3_duplicate_confidence_table using btree (normalized_phone) TABLESPACE pg_default;

create index IF not exists agents_3_duplicate_confidence_table_agent_email_zw_idx on public.agents_3_duplicate_confidence_table using btree (agent_email_zw) TABLESPACE pg_default;