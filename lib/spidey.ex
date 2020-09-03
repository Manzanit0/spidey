defmodule Spidey do
  @moduledoc """
  Spidey is a basic web crawler which runs through all the links of a same
  domain and outputs them in a simple text sitemap format.
  """

  alias Spidey.Core.UrlStore
  alias Spidey.Core.Queue
  alias Spidey.Core.File

  @doc "Crawls a website for all the same-domain urls, returning a list."
  def crawl(url) when is_binary(url) do
    UrlStore.init()
    UrlStore.add(url)
    Queue.push(url)

    {:ok, supervisor_pid} = Spidey.Core.WorkerSupervisor.start_link(seed: url, work_size: 5)

    results = await_children_termination(supervisor_pid)

    Process.exit(supervisor_pid, :normal)

    results
  end

  @doc "Crawls a website for all the sam-domain urls and Saves the list of urls to file"
  def crawl_to_file(url, path) when is_binary(url) do
    url
    |> crawl()
    |> File.save(path)
  end

  defp await_children_termination(supervisor_pid) do
    case Supervisor.count_children(supervisor_pid) do
      %{active: 0} ->
        UrlStore.retrieve_all()

      _ ->
        Process.sleep(200)
        await_children_termination(supervisor_pid)
    end
  end
end
