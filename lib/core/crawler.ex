defmodule Spidey.Core.Crawler do
  defmodule CrawlResult do
    defstruct [:pending, :seed]
  end

  alias Spidey.Core.Filters
  alias Spidey.Core.ResourceQueue, as: Queue
  alias Spidey.Core.UrlStore

  @content Application.get_env(:spidey, :content)

  def new(url) do
    UrlStore.add(url)

    %CrawlResult{seed: url, pending: [url]}
  end

  def crawl(%CrawlResult{pending: []}), do: UrlStore.retrieve_all()

  def crawl(%CrawlResult{} = cr) do
    cr.pending
    |> scan_async()
    |> Filters.process_relative_urls(cr.seed)
    |> Filters.strip_query_params()
    |> Filters.strip_trailing_slashes()
    |> Enum.reject(&UrlStore.exists?/1)
    |> Filters.reject_non_domain_urls(cr.seed)
    |> Filters.reject_invalid_urls()
    |> Filters.reject_static_resources()
    |> Enum.uniq()
    |> Enum.map(&push_to_stores/1)

    crawl(%CrawlResult{cr | pending: Queue.take(20)})
  end

  def scan(url) when is_binary(url) do
    try do
      url
      |> @content.get!()
      |> @content.parse_links()
    rescue
      # Timeout, wrong url, etc.
      e in HTTPoison.Error ->
        IO.inspect(e, label: :url_scan_error)
        []

      # non-html format
      e in CaseClauseError ->
        IO.inspect(e, label: :url_scan_error)
        []
    end
  end

  def scan_async([]), do: []

  def scan_async(urls) when is_list(urls) do
    urls
    |> Enum.map(fn url -> Task.async(fn -> scan(url) end) end)
    |> Enum.map(fn t -> Task.await(t, 30_000) end)
    |> List.flatten()
  end

  defp push_to_stores(url) do
    Queue.push(url)
    UrlStore.add(url)
  end
end
