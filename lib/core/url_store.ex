defmodule Spidey.Core.UrlStore do
  def add(url) do
    Registry.register(Spidey.UrlRegistry, url, url)
    :ok
  end

  def exists?(url) do
    case Registry.lookup(Spidey.UrlRegistry, url) do
      [] -> false
      [{_pid, _url}] -> true
    end
  end

  def retrieve_all do
    Registry.keys(Spidey.UrlRegistry, self())
  end
end
