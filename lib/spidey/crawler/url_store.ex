defmodule Spidey.Crawler.UrlStore do
  def init!(seed, pool_name) do
    case :ets.info(table_name(pool_name)) do
      :undefined ->
        :ets.new(table_name(pool_name), [:set, :public, :named_table])

      _ ->
        raise "ETS table with name #{table_name(pool_name)} already exists."
    end

    add(seed, pool_name)
  end

  def teardown(pool_name) do
    :ets.delete(table_name(pool_name))
  end

  def add(url, pool_name) do
    :ets.insert_new(table_name(pool_name), {url})
  end

  def exists?(url, pool_name) do
    case :ets.lookup(table_name(pool_name), url) do
      [] -> false
      _ -> true
    end
  end

  def retrieve_all(pool_name) do
    pool_name
    |> table_name()
    |> :ets.match({:"$1"})
    |> List.flatten()
  end

  defp table_name(pool_name), do: :"#{pool_name}_urls"
end
