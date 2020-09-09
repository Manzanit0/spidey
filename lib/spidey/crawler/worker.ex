defmodule Spidey.Crawler.Worker do
  use GenServer, restart: :transient

  alias Spidey.Filter
  alias Spidey.Crawler.Content
  alias Spidey.Storage.Queue
  alias Spidey.Storage.UrlStore

  require Logger

  def start_link(opts \\ []) do
    filter = Keyword.get(opts, :filter, Spidey.Filter.DefaultFilter)
    GenServer.start_link(__MODULE__, %{filter: filter})
  end

  def crawl(pid, url, seed, opts \\ []) when is_binary(url) do
    Logger.info("handling url: #{url}")
    timeout = Keyword.get(opts, :timeout, 60_000)
    GenServer.call(pid, {:work, url, seed}, timeout)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:work, url, seed}, _from, %{filter: filter} = state) do
    url
    |> Content.scan()
    |> Filter.filter_urls(filter, seed: seed)
    |> Enum.map(&push_to_stores/1)

    {:reply, :ok, state}
  end

  defp push_to_stores(url) do
    Queue.push(url)
    UrlStore.add(url)
  end
end
