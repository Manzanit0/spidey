defmodule Spidey.Core.WorkerSupervisor do
  use Supervisor

  alias Spidey.Core.Worker

  def start_link(opts) do
    seed = Keyword.get(opts, :seed)
    work_size = Keyword.get(opts, :work_size, 5)
    pool_size = Keyword.get(opts, :pool_size, 5)

    Supervisor.start_link(
      __MODULE__,
      %{
        seed: seed,
        work_size: work_size,
        pool_size: pool_size
      },
      name: __MODULE__
    )
  end

  @impl true
  def init(%{seed: seed, work_size: work_size, pool_size: pool_size}) do
    children =
      for n <- 0..pool_size, into: [] do
        Supervisor.child_spec({Worker, [seed: seed, work_size: work_size]}, id: :"worker#{n}")
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
