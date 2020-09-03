defmodule Spidey.Core.Crawler do
  alias Spidey.Core.Filters
  alias Spidey.Core.UrlStore

  @content Application.get_env(:spidey, :content)

  def crawl(urls, seed) do
    urls
    |> scan_async()
    |> Filters.process_relative_urls(seed)
    |> Filters.strip_query_params()
    |> Filters.strip_trailing_slashes()
    |> Enum.reject(&UrlStore.exists?/1)
    |> Filters.reject_non_domain_urls(seed)
    |> Filters.reject_invalid_urls()
    |> Filters.reject_static_resources()
    |> Enum.uniq()
  end

  defp scan_async([]), do: []

  defp scan_async(urls) when is_list(urls) do
    urls
    |> Enum.map(fn url -> Task.async(fn -> scan(url) end) end)
    |> Enum.map(fn t -> Task.await(t, 30_000) end)
    |> List.flatten()
  end

  defp scan(url) when is_binary(url) do
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
end
