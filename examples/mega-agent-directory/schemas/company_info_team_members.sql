create table public."Company Info Team Members" (
  member_id uuid not null default gen_random_uuid (),
  company_uuid uuid not null,
  team_id text null,
  name text null,
  email text null,
  phone text null,
  designation text null,
  created_at timestamp with time zone null default now(),
  "Team_size" bigint null,
  duplicate name text null,
  "Match" text null,
  "NU_diff_team" text null,
  "to be updated in NU" text null,
  "NU_Estimated_TS" bigint null,
  confidence text null,
  constraint Company Info Team Members_pkey primary key (member_id),
  constraint fk_companyinfo foreign KEY (company_uuid) references company_info (uuid) on delete CASCADE
) TABLESPACE pg_default;

-- connected to company_info table via company_uuid foreign key. 
-- This table will store information about team members of a company, 
-- including their name, email, phone, designation, and other relevant details. 
--The "Team_size" column can be used to store the number of members in the team, 
--while the "duplicate name", "Match", "NU_diff_team", "to be updated in NU",
-- "NU_Estimated_TS", and "confidence" columns can be used for data quality and
-- enrichment purposes.

