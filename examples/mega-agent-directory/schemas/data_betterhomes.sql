create table public."Data_BetterHomes" (
  uuid uuid not null default gen_random_uuid (),
  "Full_Name" text null,
  "Company" text null,
  "Email" text null,
  "Mobile" text null,
  "Fax" text null,
  "Agent_Profile_URL" text null,
  normalized_full_name text null,
  normalized_email text null,
  normalized_mobile text null,
  normalized_fax text null,
  constraint Data_BetterHomes_pkey primary key (uuid)
) TABLESPACE pg_default;

create index IF not exists idx_bh_normalized_email on public."Data_BetterHomes" using btree (normalized_email) TABLESPACE pg_default;

create index IF not exists idx_bh_normalized_mobile on public."Data_BetterHomes" using btree (normalized_mobile) TABLESPACE pg_default;

create index IF not exists idx_bh_normalized_name on public."Data_BetterHomes" using btree (normalized_full_name) TABLESPACE pg_default;