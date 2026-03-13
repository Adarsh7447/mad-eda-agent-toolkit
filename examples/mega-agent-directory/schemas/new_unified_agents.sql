create table public.new_unified_agents (
  supabase_uuid uuid not null,
  first_name text null,
  last_name text null,
  email text[] null,
  phone text[] null,
  city text[] null,
  state text[] null,
  zip_code text[] null,
  full_address text[] null,
  profile_link text null,
  website text null,
  photo_url text null,
  about text null,
  experience_years integer null,
  job_title text[] null,
  agent_designation text[] null,
  team_id text null,
  average_price numeric null,
  for_sale_count integer null,
  for_sale_min numeric null,
  for_sale_max numeric null,
  mls_number text null,
  zillow_id text null,
  zillow_address_url text null,
  social_links jsonb null,
  original_uuids text[] null,
  organization_names text[] null,
  office_number text[] null,
  updated_at timestamp with time zone not null default CURRENT_TIMESTAMP,
  sales_last_12_months bigint[] null,
  total_sales bigint null,
  website_clean text null,
  zillow_review integer null,
  zillow_rating double precision null,
  zillow_team_status text null,
  zillow_top_agent text null,
  google_rating double precision null,
  google_rating_count integer null,
  tech_stack jsonb[] null,
  team_page_url text null,
  team_size_count integer null,
  team_size text null,
  sales_marketing_team integer null,
  team_name text null,
  brokerage_name text null,
  realtor_review integer null,
  realtor_rating double precision null,
  zillow_premium text null,
  realtor_premium text null,
  is_luxury_agents_kw boolean null,
  bhhs_team_page_urls text null,
  rashi_crm jsonb null,
  full_name text null,
  source text[] null,
  shailja_brokerage text null,
  facebook text null,
  instagram text null,
  youtube text null,
  twitter text null,
  tiktok text null,
  linkedin text null,
  "CRM" text null,
  marketing_tools text null,
  social_label text null,
  "social_Score" bigint null,
  phone_digits text[] null,
  email_clean text[] null,
  "marketingTools_combined" text null,
  "CRM_sorted" text null,
  marketing_sorted text null,
  review_status text null,
  fello_customer_status text null,
  fello_customer_uuid uuid null,
  review_comments text null,
  crm_main text[] null,
  average_price_main numeric[] null,
  fello_customer_status_main text[] null,
  team_size_main text[] null,
  brokerage_name_main text[] null,
  marketing_main text[] null,
  rt_verified_agent_main text[] null,
  source_1 text[] null,
  entity text[] null,
  maps_id uuid null,
  is_primary_contact boolean null,
  agent_designation_ai text null,
  constraint pk_new_unified_agents primary key (supabase_uuid)
) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_original_uuids on public.new_unified_agents using gin (original_uuids) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_phone_digits on public.new_unified_agents using gin (phone_digits) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_source on public.new_unified_agents using gin (source) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_supabase_uuid on public.new_unified_agents using btree (supabase_uuid) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_team_id on public.new_unified_agents using btree (team_id) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_team_size_main on public.new_unified_agents using gin (team_size_main) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_average_price_main on public.new_unified_agents using gin (average_price_main) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_brokerage_name_main on public.new_unified_agents using gin (brokerage_name_main) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_crm_main on public.new_unified_agents using gin (crm_main) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_email on public.new_unified_agents using gin (email) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_email_clean on public.new_unified_agents using gin (email_clean) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_fello_customer_status_main on public.new_unified_agents using gin (fello_customer_status_main) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_marketing_main on public.new_unified_agents using gin (marketing_main) TABLESPACE pg_default;

create index IF not exists idx_new_unified_agents_missing_name_source on public.new_unified_agents using btree (supabase_uuid) TABLESPACE pg_default
where
  (
    (full_name is null)
    or (source is null)
  );

create index IF not exists idx_nua_team_id_null on public.new_unified_agents using btree (supabase_uuid) TABLESPACE pg_default
where
  (
    (team_id is null)
    or (team_id = ''::text)
  );

create index IF not exists idx_new_unified_agents_email_gin on public.new_unified_agents using gin (email) TABLESPACE pg_default;

create index IF not exists idx_nua_team_id_missing on public.new_unified_agents using btree (supabase_uuid) TABLESPACE pg_default
where
  (
    (team_id is null)
    or (team_id = ''::text)
  );

create index IF not exists idx_nua_original_uuids on public.new_unified_agents using gin (original_uuids) TABLESPACE pg_default;

create index IF not exists new_unified_agents_team_page_url_idx on public.new_unified_agents using btree (team_page_url) TABLESPACE pg_default;

create index IF not exists new_unified_agents_team_size_count_idx on public.new_unified_agents using btree (team_size_count) TABLESPACE pg_default;