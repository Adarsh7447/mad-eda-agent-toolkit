create table public."Data_Epique" (
  uuid uuid not null default gen_random_uuid (),
  first_name text null,
  last_name text null,
  full_name text null,
  email text null,
  phone text null,
  position text null,
  licence text null,
  website text null,
  facebook text null,
  instagram text null,
  twitter text null,
  youtube text null,
  linkedin text null,
  google_maps text null,
  agent_url text null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_phone text null,
  constraint data_epique_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_epique_normalized_email on public."Data_Epique" using btree (normalized_email) TABLESPACE pg_default;

create index IF not exists idx_epique_normalized_name on public."Data_Epique" using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_epique_normalized_phone on public."Data_Epique" using btree (normalized_phone) TABLESPACE pg_default;