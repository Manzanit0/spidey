defmodule Spidey.Crawler.Worker do
  use GenServer, restart: :transient

  alias Spidey.Filter
  alias Spidey.Crawler.{Content, Queue, UrlStore}
  alias Spidey.Logger

  def start_link(opts \\ []) do
    Logger.log("starting worker process")

    filter = Keyword.get(opts, :filter, Filter.DefaultFilter)
    GenServer.start_link(__MODULE__, %{filter: filter})
  end

  def crawl(pid, url, pool_name, seed, opts \\ []) when is_binary(url) do
    Logger.log("pool #{pool_name} handling url: #{url}")
    timeout = Keyword.get(opts, :timeout, 60_000)
    GenServer.call(pid, {:work, url, pool_name, seed}, timeout)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:work, url, pool_name, seed}, _from, %{filter: filter} = state) do
    url
    |> Content.scan()
    |> Filter.filter_urls(filter, seed: seed)
    |> Stream.reject(&UrlStore.exists?(&1, pool_name))
    |> Enum.each(&push_to_stores(&1, pool_name))

    {:reply, :ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.log("worker terminated due to #{inspect(reason)}")
  end

  defp push_to_stores(url, pool_name) do
    Queue.push(url, pool_name)
    UrlStore.add(url, pool_name)
  end
end
