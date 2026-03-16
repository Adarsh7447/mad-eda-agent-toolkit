create table public."Data_OneReal" (
  uuid uuid not null default gen_random_uuid (),
  "FirstName" text null,
  "LastName" text null,
  "DisplayName" text null,
  "Email" text null,
  "Phone" text null,
  "Addresses" jsonb null,
  "Divisions" jsonb null,
  "ProfileURL" text null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_phone text null,
  constraint Data_OneReal_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_onereal_normalized_email on public."Data_OneReal" using btree (normalized_email) TABLESPACE pg_default;

create index IF not exists idx_onereal_normalized_name on public."Data_OneReal" using btree (normalized_full_name) TABLESPACE pg_default;

create index IF not exists idx_onereal_normalized_phone on public."Data_OneReal" using btree (normalized_phone) TABLESPACE pg_default;