defmodule Spidey.Crawler do
  alias Spidey.Storage.UrlStore
  alias Spidey.Storage.Queue
  alias Spidey.Crawler.Worker

  @worker_timeout 60_000

  def crawl(seed, pool_name) do
    UrlStore.init(seed)
    Queue.push(seed, pool_name)

    results = crawl_queue(pool_name, seed)

    results
  end

  defp crawl_queue(pool_name, seed) do
    queue_length = Queue.length(pool_name)

    if queue_length == 0 do
      UrlStore.retrieve_all()
    else
      queue_length
      |> Queue.take(pool_name)
      |> Enum.map(&run_in_pool(&1, pool_name, seed))
      |> Enum.map(&Task.await(&1, @worker_timeout))

      crawl_queue(pool_name, seed)
    end
  end

  defp run_in_pool(url, pool_name, seed) do
    Task.async(fn ->
      :poolboy.transaction(
        pool_name,
        fn pid -> Worker.crawl(pid, url, pool_name, seed, timeout: @worker_timeout) end,
        @worker_timeout
      )
    end)
  end
end
