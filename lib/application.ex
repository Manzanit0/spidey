defmodule Spidey.Application do
  use Application

  def start(_type, args) do
    pool_opts = Keyword.take(args, [:filter])

    children = [
      {Spidey.Core.Queue, []},
      :poolboy.child_spec(:crawler_pool, poolboy_config(), pool_opts)
    ]

    opts = [strategy: :one_for_one, name: Spidey.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp poolboy_config do
    [
      name: {:local, :crawler_pool},
      worker_module: Spidey.Core.Worker,
      size: 20,
      max_overflow: 5
    ]
  end
end
