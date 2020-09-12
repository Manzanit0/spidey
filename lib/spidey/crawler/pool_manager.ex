defmodule Spidey.Crawler.PoolManager do
  @moduledoc """
  PoolManager is in charge of spinning up the pools and queues to crawl new
  websites. Every time a new website is to be crawled, a pool is created,
  along with a queue. When the job has been finished, they are terminated.
  """

  use DynamicSupervisor

  alias Spidey.Crawler.PoolSupervisor

  @doc "Starts the supervisor."
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc "Starts a pool of crawlers and a queue under the supervisor."
  def start_child(pool_name, opts \\ []) do
    case Registry.lookup(Spidey.Registry, pool_name) do
      [_] ->
        {:error, :already_exists}

      [] ->
        child_spec = PoolSupervisor.child_spec(pool_name, opts)
        DynamicSupervisor.start_child(__MODULE__, child_spec)
    end
  end

  @doc "Terminates both the pool of crawlers and the queue they use."
  def terminate_child(pool_name) do
    case Registry.lookup(Spidey.Registry, pool_name) do
      [{_, %{pid: pid}}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      [] ->
        {:error, :not_found}
    end
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5
    )
  end
end
