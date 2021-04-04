defmodule Spidey.Crawler do
  require Logger
  alias Spidey.Crawler.{PoolManager, UrlStore, Queue, Worker}

  @worker_timeout 60_000

  def crawl(seed, pool_name, opts) do
    try do
      Logger.info("starting pool and ETS table #{pool_name}")
      PoolManager.start_child(pool_name, opts)
      UrlStore.init!(seed, pool_name)

      Queue.push(seed, pool_name)
      crawl_queue(pool_name, seed)
    after
      Logger.info("terminating pool and ETS table #{pool_name}")
      PoolManager.terminate_child(pool_name)
      UrlStore.teardown(pool_name)
    end
  end

  defp crawl_queue(pool_name, seed) do
    queue_length = Queue.length(pool_name)

    if queue_length == 0 do
      UrlStore.retrieve_all(pool_name)
    else
      queue_length
      |> Queue.take(pool_name)
      |> Enum.map(&run_in_pool(&1, pool_name, seed))
      |> Task.await_many(@worker_timeout)

      crawl_queue(pool_name, seed)
    end
  end

  defp run_in_pool(url, pool_name, seed) do
    Task.async(fn ->
      :poolboy.transaction(
        pool_name,
        fn pid -> Worker.crawl(pid, url, pool_name, seed, timeout: @worker_timeout - 5000) end,
        @worker_timeout
      )
    end)
  end
end
