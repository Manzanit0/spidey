defmodule Spidey.Core.Crawler do
  defmodule CrawlResult do
    defstruct [:scanned, :pending, :seed]
  end

  alias Spidey.Core.Filters
  alias Spidey.Core.ResourceQueue, as: Queue

  @content Application.get_env(:spidey, :content)

  def new(url) do
    %CrawlResult{seed: url, scanned: [], pending: [url]}
  end

  def crawl(%CrawlResult{pending: []} = cr), do: Enum.uniq(cr.scanned)

  def crawl(%CrawlResult{} = cr) do
    cr.pending
    |> scan_async()
    |> Filters.process_relative_urls(cr.seed)
    |> Filters.reject_non_domain_urls(cr.seed)
    |> Filters.reject_already_scanned_urls(cr.scanned ++ cr.pending)
    |> Filters.reject_invalid_urls()
    |> Enum.uniq()
    |> Enum.map(&Queue.push/1)

    crawl(%CrawlResult{cr | scanned: cr.scanned ++ cr.pending, pending: Queue.take(20)})
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
    |> Enum.map(fn t -> Task.await(t, 15_000) end)
    |> List.flatten()
  end
end
