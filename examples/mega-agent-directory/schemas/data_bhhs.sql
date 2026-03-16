create table public."Data_BHHS" (
  uuid uuid not null default gen_random_uuid (),
  id text null,
  first_name text null,
  last_name text null,
  full_name text null,
  city text null,
  state text null,
  languages text[] null,
  email text null,
  license text null,
  mobile_phone text null,
  office_phone text null,
  fax text null,
  address text null,
  postal_code text null,
  country text null,
  job_title text null,
  team_name text null,
  team_id text null,
  team_url text null,
  office_name text null,
  office_key text null,
  is_luxury_agent boolean null default false,
  marketing_title text null,
  market_center_name text null,
  favorite_service_areas text[] null,
  designations text[] null,
  bhhswebsite_url text null,
  member_url text null,
  commercial boolean null default false,
  social_facebook text null,
  social_linkedin text null,
  social_twitter text null,
  social_youtube text null,
  social_instagram text null,
  social_pinterest text null,
  social_googleplus text null,
  social_tumblr text null,
  typename text null,
  market_center_typename text null,
  social_typename text null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_mobile text null,
  normalized_office_phone text null,
  team_summary_id uuid null,
  team_summary_id_text text GENERATED ALWAYS as ((team_summary_id)::text) STORED null,
  constraint Data_BHHS_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_bhhs_normalized_email on public."Data_BHHS" using btree (normalized_email) TABLESPACE pg_default;

create index IF not exists idx_bhhs_normalized_mobile on public."Data_BHHS" using btree (normalized_mobile) TABLESPACE pg_default;

create index IF not exists idx_bhhs_normalized_name on public."Data_BHHS" using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_bhhs_team_summary_id_text on public."Data_BHHS" using btree (team_summary_id_text) TABLESPACE pg_default
where
  (team_summary_id is not null);