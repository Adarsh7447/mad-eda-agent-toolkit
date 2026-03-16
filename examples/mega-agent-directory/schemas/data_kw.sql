create table public."Data_KW" (
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
  is_luxury_agent boolean null,
  marketing_title text null,
  market_center_name text null,
  favorite_service_areas text[] null,
  social_facebook text null,
  social_linkedin text null,
  social_twitter text null,
  social_youtube text null,
  social_instagram text null,
  typename text null,
  market_center_typename text null,
  social_typename text null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_phone text null,
  team_summary_id text null,
  normalized_market_center text null,
  uuid_text text GENERATED ALWAYS as ((uuid)::text) STORED null,
  constraint Data_KW_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_data_kw_uuid_text_team on public."Data_KW" using btree (uuid_text) TABLESPACE pg_default
where
  (team_summary_id is not null);

create index IF not exists idx_kw_uuid_text_team on public."Data_KW" using btree (uuid_text) TABLESPACE pg_default
where
  (team_summary_id is not null);