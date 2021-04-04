defmodule Spidey.Crawler.UrlStore do
  def init!(seed, pool_name) do
    if table_exists?(pool_name) do
      raise "ETS table with name #{table_name(pool_name)} already exists."
    end

    :ets.new(table_name(pool_name), [:set, :public, :named_table])
    add(seed, pool_name)
  end

  def teardown(pool_name) do
    with true <- table_exists?(pool_name) do
      :ets.delete(table_name(pool_name))
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  def add(url, pool_name) do
    with true <- table_exists?(pool_name) do
      :ets.insert_new(table_name(pool_name), {url})
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  def exists?(url, pool_name) do
    with true <- table_exists?(pool_name) do
      case :ets.lookup(table_name(pool_name), url) do
        [] -> false
        _ -> true
      end
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  def retrieve_all(pool_name) do
    with true <- table_exists?(pool_name) do
      pool_name
      |> table_name()
      |> :ets.match({:"$1"})
      |> List.flatten()
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  defp table_name(pool_name), do: :"#{pool_name}_urls"

  defp table_exists?(pool_name), do: :undefined != :ets.info(table_name(pool_name))
end
