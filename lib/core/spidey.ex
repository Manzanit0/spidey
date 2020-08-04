defmodule Core.CrawlResult do
  defstruct [:scanned, :pending, :seed]
end

defmodule Core.Spidey do
  alias Core.CrawlResult
  alias Core.Filters

  @content Application.get_env(:spidey, :content)

  def new(url) do
    %CrawlResult{seed: url, scanned: [], pending: [url]}
  end

  def crawl(%CrawlResult{scanned: scanned, pending: []}) do
    Enum.uniq(scanned)
  end

  def crawl(%CrawlResult{pending: pending, scanned: scanned, seed: seed} = cr) do
    results =
      pending
      |> scan_async()
      |> Filters.process_relative_urls(seed)
      |> Filters.already_scanned_urls(scanned ++ pending)
      |> Filters.non_domain_urls(seed)
      |> Enum.uniq()

    crawl(%CrawlResult{cr | pending: results, scanned: scanned ++ pending})
  end

  def scan(url) when is_binary(url) do
    try do
      url
      |> @content.get!()
      |> @content.parse_links()
    rescue
      # Timeout, wrong url, etc.
      e in HTTPoison.Error ->
        IO.inspect(e)
        []

      # non-html format
      e in CaseClauseError ->
        IO.inspect(e)
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
