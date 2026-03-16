create table public.wsj_real_trends_teams_small (
  id uuid not null default gen_random_uuid (),
  "Team_Name" text null,
  "Brokerage" text null,
  "Rank_2025" smallint null,
  "Volume" text null,
  "Sides" real null,
  "Location" text null,
  "Size" text null,
  "Website" text null,
  constraint wsj_real_trends_teams_New_Small_pkey primary key (id)
) TABLESPACE pg_default;