defmodule Spidey.Core.Worker do
  use GenServer, restart: :transient

  alias Spidey.Core.Crawler
  alias Spidey.Core.Queue
  alias Spidey.Core.UrlStore

  require Logger

  def start_link(seed: seed, work_size: work_size) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{seed: seed, work_size: work_size})
    Process.send(pid, {:work, 0}, [])

    Logger.info("started worker #{inspect(pid)}")
    {:ok, pid}
  end

  @impl true
  def init(seed) do
    {:ok, seed}
  end

  @impl true
  def handle_info({:work, 3}, _state) do
    {:stop, :normal, %{}}
  end

  @impl true
  def handle_info({:work, retries}, %{seed: seed, work_size: work_size} = state) do
    if Queue.length() > 0 do
      work_size
      |> Queue.take()
      |> Crawler.crawl(seed)
      |> Enum.map(fn url ->
        Queue.push(url)
        UrlStore.add(url)
      end)

      Process.send(self(), {:work, 0}, [])
    else
      # If there is no work to do, wait a little and retry, up to 3 times.
      Process.send_after(self(), {:work, retries + 1}, retries * 800)
    end

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("terminating worker #{inspect(self())} due to #{reason}")
    state
  end
end
