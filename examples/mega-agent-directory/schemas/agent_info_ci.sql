create table public.agent_info_ci (
  id uuid not null default gen_random_uuid (),
  agent_uuid uuid not null,
  team_id text null,
  agent_name text null,
  phone text null,
  designation text null,
  raw_json jsonb null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint agent_info_ci_pkey primary key (id),
  constraint unique_agent_per_company unique (agent_uuid, team_id, agent_name)
) TABLESPACE pg_default;

create index IF not exists idx_agent_info_ci_agent_uuid on public.agent_info_ci using btree (agent_uuid) TABLESPACE pg_default;

create index IF not exists idx_agent_info_ci_team_id on public.agent_info_ci using btree (team_id) TABLESPACE pg_default;