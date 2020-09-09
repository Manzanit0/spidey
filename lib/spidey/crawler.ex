defmodule Spidey.Crawler do
  alias Spidey.Storage.UrlStore
  alias Spidey.Storage.Queue
  alias Spidey.Crawler.Worker

  @worker_timeout 60_000

  def crawl(seed) do
    UrlStore.init(seed)
    Queue.push(seed)

    crawl_queue(seed)
  end

  defp crawl_queue(seed) do
    queue_length = Queue.length()

    if queue_length == 0 do
      UrlStore.retrieve_all()
    else
      queue_length
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
        fn pid -> Worker.crawl(pid, url, seed, timeout: @worker_timeout) end,
        @worker_timeout
      )
    end)
  end
end
