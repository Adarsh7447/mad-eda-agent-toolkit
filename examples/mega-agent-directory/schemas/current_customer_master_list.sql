create table public."Current_Customer_Master_List" (
  "Record ID - Contact" bigint null,
  "First Name" text null,
  "Last Name" text null,
  "Email" text null,
  "Phone Number" text null,
  "Contact owner" text null,
  "Last Activity Date" text null,
  "Lead Status" text null,
  "Marketing contact status" text null,
  "Create Date" text null,
  "Record ID - Company" text null,
  "Company name" text null,
  "Company owner" text null,
  "Create Date_1" text null,
  "Phone Number_1" text null,
  "Last Activity Date_1" text null,
  "City" text null,
  "Country/Region" text null,
  "Industry" text null,
  "Added To List On" text null
) TABLESPACE pg_default;

create index IF not exists idx_current_email on public."Current_Customer_Master_List" using btree ("Email") TABLESPACE pg_default;

create index IF not exists idx_current_phone on public."Current_Customer_Master_List" using btree ("Phone Number") TABLESPACE pg_default;