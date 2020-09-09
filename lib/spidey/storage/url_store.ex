defmodule Spidey.Storage.UrlStore do
  def init do
    case :ets.info(:urls) do
      :undefined -> :ets.new(:urls, [:set, :public, :named_table])
      _ -> :already_initialised
    end
  end

  def add(url) do
    :ets.insert_new(:urls, {url})
  end

  def exists?(url) do
    case :ets.lookup(:urls, url) do
      [] -> false
      _ -> true
    end
  end

  def retrieve_all do
    :ets.match(:urls, {:"$1"})
  end
end
