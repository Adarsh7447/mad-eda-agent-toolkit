create table public.agents_maps (
  id uuid not null default gen_random_uuid (),
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
  "Zillow_Review" real null,
  "Zillow_review_count" smallint null,
  designation text null,
  "Status" text null,
  team_size bigint null,
  team_summary_id uuid null,
  ts_id uuid null,
  ready_for_nua boolean null,
  constraint agents_maps_pkey primary key (id)
) TABLESPACE pg_default;

create index IF not exists agents_maps_list_name_idx on public.agents_maps using btree (list_name) TABLESPACE pg_default;

create index IF not exists agents_maps_updated_at_idx on public.agents_maps using btree (updated_at) TABLESPACE pg_default;

create index IF not exists agents_maps_team_id_idx on public.agents_maps using btree (team_id) TABLESPACE pg_default;

create index IF not exists agents_maps_personal_email_idx on public.agents_maps using btree (personal_email) TABLESPACE pg_default;