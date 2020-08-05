defmodule Spidey.Core.ResourceQueue do
  use Agent

  def start_link(urls) do
    queue = :queue.from_list(urls)
    Agent.start_link(fn -> queue end, name: __MODULE__)
  end

  def pop do
    queue = Agent.get(__MODULE__, & &1)
    {value, queue} = pop_value(queue)
    Agent.update(__MODULE__, fn _ -> queue end)
    value
  end

  def take(n) do
    1..n
    |> Enum.map(fn _ -> pop() end)
    |> Enum.reject(&(&1 == :empty))
  end

  def push(url) do
    Agent.update(__MODULE__, &:queue.in(url, &1))
  end

  defp pop_value(queue) do
    # IO.inspect("Queue size: #{:queue.len(queue)}")
    case :queue.out(queue) do
      {{:value, value}, queue} -> {value, queue}
      {:empty, queue} -> {:empty, queue}
    end
  end
end
