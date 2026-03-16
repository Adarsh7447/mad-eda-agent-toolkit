create table public."Data_Remax" (
  "First Name" text null,
  "Last Name" text null,
  "Full Name" text null,
  "job Title" text null,
  "Email 1" text null,
  "Email 2" text null,
  "Phone Number" text null,
  "Profile URL on RE/MAX" text null,
  "Website" jsonb null,
  "License Number" text null,
  "Office Name" text null,
  "Office City" text null,
  "Office State" text null,
  "Office Postal Code" text null,
  "Full Address" text null,
  "Specialty" text null,
  languages text null,
  uuid uuid not null default gen_random_uuid (),
  normalized_full_name text null,
  normalized_email text null,
  normalized_phone text null,
  normalized_license_number text null,
  deduplication_key text null,
  team_summary_id text null,
  uuid_text text GENERATED ALWAYS as ((uuid)::text) STORED null,
  constraint Data_Remax_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_data_remax_dedup on public."Data_Remax" using btree (deduplication_key) TABLESPACE pg_default;

create index IF not exists idx_data_remax_name on public."Data_Remax" using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_remax_uuid_text_team on public."Data_Remax" using btree (uuid_text) TABLESPACE pg_default
where
  (team_summary_id is not null);