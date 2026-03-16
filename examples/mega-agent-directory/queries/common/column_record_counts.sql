drop table if exists temp_null_column_counts;

create temp table temp_null_column_counts (
  table_schema text,
  table_name text,
  column_name text,
  ordinal_position integer,
  total_count bigint,
  null_count bigint,
  not_null_count bigint,
  null_percentage numeric(6,2)
);

do $$
declare
  target_table record;
  column_aggregates text;
  value_rows text;
  sql_text text;
begin
  for target_table in
    select *
    from (
      values
        ('public', 'Team_Summary'),
        ('public', 'agents_3'),
        ('public', 'agent_info_ci'),
        ('public', 'agents'),
        ('public', 'agents_2'),
        ('public', 'agents_2_duplicate_confidence_table'),
        ('public', 'agents_3_duplicate_confidence_table'),
        ('public', 'agents_4'),
        ('public', 'agents_4_duplicate_confidence_table'),
        ('public', 'agents_4_hemanth'),
        ('public', 'agents_duplicate_confidence_table'),
        ('public', 'agents_maps'),
        ('public', 'company_info'),
        ('public', 'Company Info Team Members'),
        ('public', 'Current_Customer_Master_List'),
        ('public', 'Data_AT_Properties'),
        ('public', 'Data_BetterHomes'),
        ('public', 'Data_BHHS'),
        ('public', 'Data_Epique'),
        ('public', 'Data_KW'),
        ('public', 'Data_maps_teams'),
        ('public', 'Data_OneReal'),
        ('public', 'Data_Realtor'),
        ('public', 'Data_Remax'),
        ('public', 'Fello_Customer_Churn_Status'),
        ('public', 'Fello_Customer_Status'),
        ('public', 'mad_dashboard'),
        ('public', 'new_unified_agents'),
        ('public', 'only_agents_1'),
        ('public', 'only_agents_1_duplicate'),
        ('public', 'only_agents_2'),
        ('public', 'only_agents_3'),
        ('public', 'only_agents_4'),
        ('public', 'only_agents_5'),
        ('public', 'only_agents_6'),
        ('public', 'Team_Summary_1'),
        ('public', 'Team_Summary_2'),
        ('public', 'wsj_real_trends_teams_large'),
        ('public', 'wsj_real_trends_teams_medium'),
        ('public', 'wsj_real_trends_teams_mega'),
        ('public', 'wsj_real_trends_teams_small')
    ) as t(table_schema, table_name)
  loop
    select
      string_agg(
        format(
          'count(*) filter (where %I is null) as c%s',
          c.column_name,
          c.ordinal_position
        ),
        E',\n    '
        order by c.ordinal_position
      ),
      string_agg(
        format(
          '(%L, %s, c%s)',
          c.column_name,
          c.ordinal_position,
          c.ordinal_position
        ),
        E',\n      '
        order by c.ordinal_position
      )
    into column_aggregates, value_rows
    from information_schema.columns c
    where c.table_schema = target_table.table_schema
      and c.table_name = target_table.table_name;

    if column_aggregates is null or value_rows is null then
      continue;
    end if;

    sql_text := format(
      $sql$
      insert into temp_null_column_counts (
        table_schema,
        table_name,
        column_name,
        ordinal_position,
        total_count,
        null_count,
        not_null_count,
        null_percentage
      )
      with stats as (
        select
          count(*) as total_count,
          %s
        from %I.%I
      )
      select
        %L as table_schema,
        %L as table_name,
        v.column_name,
        v.ordinal_position,
        stats.total_count,
        v.null_count,
        stats.total_count - v.null_count as not_null_count,
        round(100.0 * v.null_count / nullif(stats.total_count, 0), 2) as null_percentage
      from stats
      cross join lateral (
        values
          %s
      ) as v(column_name, ordinal_position, null_count);
      $sql$,
      column_aggregates,
      target_table.table_schema,
      target_table.table_name,
      target_table.table_schema,
      target_table.table_name,
      value_rows
    );

    execute sql_text;
  end loop;
end
$$;

select
  table_schema,
  table_name,
  column_name,
  total_count,
  null_count,
  not_null_count,
  null_percentage
from temp_null_column_counts
order by table_schema, table_name, ordinal_position;
