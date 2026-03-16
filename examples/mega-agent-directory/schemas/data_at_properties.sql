create table public."Data_AT_Properties" (
  uuid uuid not null default gen_random_uuid (),
  id bigint null,
  full_name text null,
  title text null,
  email text null,
  phone text null,
  mobile_phone text null,
  office_phone text null,
  website text null,
  team_name text null,
  office_name text null,
  office_address text null,
  city text null,
  state text null,
  zip text null,
  profile_url text null,
  social_facebook text null,
  social_linkedin text null,
  social_twitter text null,
  social_instagram text null,
  social_youtube text null,
  is_commercial boolean null,
  preferred_loan_officer_name text null,
  preferred_loan_officer_phone text null,
  preferred_loan_officer_link text null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_phone text null,
  normalized_mobile text null,
  normalized_office_phone text null,
  team_summary_id uuid null,
  constraint Data_atproperties_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_atp_normalized_email on public."Data_AT_Properties" using btree (normalized_email) TABLESPACE pg_default;

create index IF not exists idx_atp_normalized_mobile on public."Data_AT_Properties" using btree (normalized_mobile) TABLESPACE pg_default;

create index IF not exists idx_atp_normalized_name on public."Data_AT_Properties" using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_atp_normalized_phone on public."Data_AT_Properties" using btree (normalized_phone) TABLESPACE pg_default;

create index IF not exists idx_atp_team_summary_id on public."Data_AT_Properties" using btree (team_summary_id) TABLESPACE pg_default
where
  (team_summary_id is not null);