defmodule Spidey.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Spidey.Core.ResourceQueue, []},
      {Registry, [keys: :unique, name: Spidey.UrlRegistry]}
    ]

    opts = [strategy: :one_for_one, name: Spidey.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
