create table public.company_info (
  uuid uuid not null,
  website text null,
  team_members jsonb null,
  email text null,
  phone text null,
  analysis text null,
  name_count bigint null,
  team_id text null,
  "TS_team_size" text null,
  "CI_unique_name" text null,
  "CI_UniqueName_count" bigint null,
  match text null,
  calculated_team_count integer null,
  needs_verification boolean null default false,
  team_page_url text null,
  team_members_clean jsonb null,
  "NU_url_max" text null,
  "NU_url_teamCount" bigint null,
  nu_full_name text null,
  nu_full_name_cleaned text null,
  "CI_unique_data" jsonb null,
  "NU_common_names" jsonb null,
  "NU_UniqueNames_To_be_added" jsonb null,
  "CI_team_size" bigint null,
  constraint company_info_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_names_to_process on public.company_info using btree (team_id) TABLESPACE pg_default
where
  (
    ("NU_UniqueNames_To_be_added" is null)
    and ("CI_unique_data" is not null)
  );