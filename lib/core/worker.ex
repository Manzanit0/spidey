defmodule Spidey.Core.Worker do
  use GenServer, restart: :transient

  alias Spidey.Core.Filters
  alias Spidey.Core.UrlStore
  alias Spidey.Core.Queue
  alias Spidey.Core.UrlStore
  alias Spidey.Core.Content

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def crawl(pid, url, seed) when is_binary(url) do
    Logger.info("crawling url: #{url}")
    GenServer.call(pid, {:work, url, seed}, 60_000)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:work, url, seed}, _from, state) do
    url
    |> Content.scan()
    |> Filters.filter_relevant_urls(seed)
    |> Enum.map(&push_to_stores/1)

    {:reply, :ok, state}
  end

  defp push_to_stores(url) do
    Queue.push(url)
    UrlStore.add(url)
  end
end
