defmodule Spidey.Core.Crawler do
  alias Spidey.Core.UrlStore
  alias Spidey.Core.Queue
  alias Spidey.Core.Worker

  @worker_timeout 60_000

  def crawl(seed) do
    UrlStore.init()
    UrlStore.add(seed)
    Queue.push(seed)

    crawl_queue(seed)
  end

  defp crawl_queue(seed) do
    if Queue.length() == 0 do
      UrlStore.retrieve_all()
    else
      Queue.length()
      |> Queue.take()
      |> Enum.map(&crawl_via_worker(&1, seed))
      |> Enum.map(&Task.await(&1, @worker_timeout))

      crawl_queue(seed)
    end
  end

  defp crawl_via_worker(url, seed) do
    Task.async(fn ->
      :poolboy.transaction(
        :crawler_pool,
        fn pid -> Worker.crawl(pid, url, seed) end,
        @worker_timeout
      )
    end)
  end
end
