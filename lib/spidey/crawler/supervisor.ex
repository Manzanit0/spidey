defmodule Spidey.Crawler.Supervisor do
  use Supervisor

  alias Spidey.Crawler.Queue

  def start_link(pool_name, _opts) do
    Supervisor.start_link(__MODULE__, %{pool_name: pool_name}, name: :"#{pool_name}Supervisor")
  end

  @impl true
  def init(%{pool_name: pool_name}) do
    children = [
      {Task.Supervisor, name: :"#{pool_name}TaskSupervisor"},
      Queue.child_spec(pool_name)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
