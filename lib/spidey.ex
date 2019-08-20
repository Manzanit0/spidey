defmodule CrawlResult do
  defstruct [:scanned, :pending, :seed]
end

defmodule Spidey do
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
      |> filter_already_scanned_urls(scanned ++ pending)
      |> filter_non_domain_urls(seed)
      |> Enum.uniq()

    crawl(%CrawlResult{cr | pending: results, scanned: scanned ++ pending})
  end

  def scan(url) when is_binary(url) do
    url
    |> @content.get!()
    |> @content.parse_links()
  end

  def scan_async([]), do: []

  def scan_async(urls) when is_list(urls) do
    urls
    |> Enum.map(fn url -> Task.async(fn -> scan(url) end) end)
    |> Enum.map(&Task.await/1)
    |> List.flatten()
  end

  def filter_non_domain_urls(urls, seed) do
    %URI{host: seed_host} = URI.parse(seed)
    Enum.filter(urls, fn url -> URI.parse(url).host == seed_host end)
  end

  def filter_already_scanned_urls(urls, scanned) do
    Enum.filter(urls, fn x -> !Enum.member?(scanned, x) end)
  end
end
