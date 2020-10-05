defmodule EctoPSQLExtras.IndexUsage do
  @behaviour EctoPSQLExtras

  def info do
    %{
      title: "Index hit rate (effective databases are at 99% and up)",
      columns: [
        %{name: :relname, type: :string},
        %{name: :percent_of_times_index_used, type: :string},
        %{name: :rows_in_table, type: :int}
      ]
    }
  end

  def query do
    """
    /* Index hit rate (effective databases are at 99% and up) */

    SELECT relname,
       CASE idx_scan
         WHEN 0 THEN 'Insufficient data'
         ELSE (100 * idx_scan / (seq_scan + idx_scan))::text
       END percent_of_times_index_used,
       n_live_tup rows_in_table
     FROM
       pg_stat_user_tables
     ORDER BY
       n_live_tup DESC;
    """
  end
end
