create table public."Team_Summary_2" (
  uuid uuid not null default gen_random_uuid (),
  team_name text null,
  team_id text null,
  team_size_count integer null,
  brokerage text null,
  state text null,
  city text null,
  zip_code text null,
  source text null,
  size text null,
  rank_2025 smallint null,
  volume text null,
  sides real null,
  "Website" text null,
  fello_customer_status text null,
  entity text null,
  team_crm_main text[] null,
  uuid_text text null,
  rt_verified_team_main text[] null,
  "Status" text null,
  normalized_entity text null,
  team_club_id text null,
  normalized_team_name text null,
  match text null,
  constraint team_summary_bhhs_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_team_summary_uuid on public."Team_Summary_2" using btree (uuid) TABLESPACE pg_default;

create index IF not exists idx_team_summary_status_match_null on public."Team_Summary_2" using btree (uuid) TABLESPACE pg_default
where
  (
    ("Status" is null)
    and (match is null)
  );