defmodule Spidey.Crawler.PoolSupervisor do
  use Supervisor

  alias Spidey.Crawler.{PoolSupervisor, Worker, Queue}

  def start_link(pool_name, opts) do
    Supervisor.start_link(__MODULE__, %{pool_name: pool_name, opts: opts},
      name: :"#{pool_name}Supervisor"
    )
  end

  def child_spec(pool_name, opts) do
    %{
      id: :"#{pool_name}Supervisor",
      start: {PoolSupervisor, :start_link, [pool_name, opts]}
    }
  end

  @impl true
  def init(%{pool_name: pool_name, opts: opts}) do
    pool_size = Keyword.get(opts, :pool_size, 20)
    max_overflow = Keyword.get(opts, :max_overflow, 5)

    worker_opts = Keyword.take(opts, [:filter])

    config = [
      name: {:local, pool_name},
      worker_module: Worker,
      size: pool_size,
      max_overflow: max_overflow
    ]

    children = [
      :poolboy.child_spec(pool_name, config, worker_opts),
      Queue.child_spec(pool_name)
    ]

    Registry.register(Spidey.Registry, pool_name, %{pid: self()})

    Supervisor.init(children, strategy: :one_for_all)
  end
end
