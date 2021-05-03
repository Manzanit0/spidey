defmodule Spidey.Crawler.CrawlerSupervisor do
  use Supervisor

  alias Spidey.Crawler.Queue

  @spec start_link(atom(), Keyword.t()) :: Supervisor.on_start()
  def start_link(crawler_name, _opts) do
    Supervisor.start_link(__MODULE__, %{crawler_name: crawler_name},
      name: :"#{crawler_name}Supervisor"
    )
  end

  @impl true
  def init(%{crawler_name: crawler_name}) do
    children = [
      {Task.Supervisor, name: task_supervisor_name(crawler_name)},
      Queue.child_spec(crawler_name)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def task_supervisor_name(crawler_name), do: :"#{crawler_name}TaskSupervisor"
end
