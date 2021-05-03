defmodule Spidey.Crawler.UrlStore do
  def init!(seed, name) do
    if table_exists?(name) do
      raise "ETS table with name #{table_name(name)} already exists."
    end

    :ets.new(table_name(name), [:set, :public, :named_table])
    add(seed, name)
  end

  def teardown(name) do
    with true <- table_exists?(name) do
      :ets.delete(table_name(name))
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  def add(url, name) do
    with true <- table_exists?(name) do
      :ets.insert_new(table_name(name), {url})
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  def exists?(url, name) do
    with true <- table_exists?(name) do
      case :ets.lookup(table_name(name), url) do
        [] -> false
        _ -> true
      end
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  def retrieve_all(name) do
    with true <- table_exists?(name) do
      name
      |> table_name()
      |> :ets.match({:"$1"})
      |> List.flatten()
    else
      _ ->
        {:error, :undefined_table}
    end
  end

  defp table_name(name), do: :"#{name}_urls"

  defp table_exists?(name), do: :undefined != :ets.info(table_name(name))
end
