create table public."Data_Realtor" (
  "Experience" bigint null,
  "Full Name" text null,
  "Description" text null,
  "Website" text null,
  "Profile Url" text null,
  "Photo Url" text null,
  "Languages" text null,
  "Recommendations Count" text null,
  "Email" text null,
  "Social Media Urls" text null,
  "For Sale Count" bigint null,
  "For Sale Min" bigint null,
  "For Sale Max" bigint null,
  "Recently Sold Count" bigint null,
  "Recently Sold Min" bigint null,
  "Recently Sold Max" bigint null,
  "Address" text null,
  "Office Name" text null,
  "Office" text null,
  "Mobile" text null,
  "Fax" text null,
  "City" text null,
  "State" text null,
  source_state text null,
  "UUID" uuid not null,
  processing_batch bigint null,
  batch_id integer null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_phone text null,
  normalized_license_number text null,
  deduplication_key text null,
  team_summary_id text null,
  multi_source text null,
  flag text null,
  uuid_text text null default (extensions.uuid_generate_v4 ())::text,
  constraint Data_Realtor_pkey primary key ("UUID")
) TABLESPACE pg_default;

create index IF not exists idx_data_realtor_flag_uuid on public."Data_Realtor" using btree ("UUID") TABLESPACE pg_default
where
  (flag = 'yes'::text);

create index IF not exists idx_data_realtor_dedup on public."Data_Realtor" using btree (deduplication_key) TABLESPACE pg_default;

create index IF not exists idx_data_realtor_name on public."Data_Realtor" using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_data_realtor_uuid on public."Data_Realtor" using btree ("UUID") TABLESPACE pg_default;

create index IF not exists idx_data_realtor_uuid_text_flag_yes on public."Data_Realtor" using btree (uuid_text) TABLESPACE pg_default
where
  (flag = 'yes'::text);