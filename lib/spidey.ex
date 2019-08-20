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
      |> process_relative_urls(seed)
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
    |> Enum.map(fn t -> Task.await(t, 15_000) end)
    |> List.flatten()
  end

  def filter_non_domain_urls(urls, seed) do
    %URI{host: seed_host} = URI.parse(seed)
    Enum.filter(urls, fn url -> URI.parse(url).host == seed_host end)
  end

  def filter_already_scanned_urls(urls, scanned) do
    Enum.filter(urls, fn x -> !Enum.member?(scanned, x) end)
  end

  def process_relative_urls(urls, seed) do
    Enum.map(urls, fn url -> to_absolute_url(url, seed) end)
  end

  defp to_absolute_url(url, seed) do
    with %URI{scheme: s, host: h, path: p} <- URI.parse(url),
         scheme <- scheme(s),
         host <- host(h, seed),
         path <- path(p)
    do
      scheme <> host <> path
    else
      :error -> ""
    end
  end

  defp scheme("https"), do: "https://"
  defp scheme(_other), do: "http://"

  defp host(h, _) when h != nil and h != "", do: h
  defp host(_, seed) when seed != nil and seed != "", do: seed
  defp host(_, _), do: {:error, "nil or empty host"}

  defp path(nil), do: "/"
  defp path(""), do: "/"
  defp path(p), do: p
end
