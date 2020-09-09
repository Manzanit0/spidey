defmodule Spidey.Filter.DefaultFilter do
  @behaviour Spidey.Filter

  alias Spidey.Storage.UrlStore

  @impl true
  def filter_urls(urls, seed: seed) do
    urls
    |> process_relative_urls(seed)
    |> strip_query_params()
    |> strip_trailing_slashes()
    |> Stream.reject(&UrlStore.exists?/1)
    |> reject_non_domain_urls(seed)
    |> reject_invalid_urls()
    |> reject_static_resources()
    |> Stream.uniq()
  end

  def strip_query_params(urls) do
    Stream.map(urls, fn s -> String.split(s, "?") |> List.first() end)
  end

  def strip_trailing_slashes(urls) do
    Stream.map(urls, fn s -> String.replace_trailing(s, "/", "") end)
  end

  def reject_invalid_urls(urls) do
    urls
    |> Stream.reject(&is_nil/1)
    |> Stream.reject(&(&1 == ""))
  end

  def reject_static_resources(urls) do
    urls
    # Wordpress links
    |> Stream.reject(&String.contains?(&1, "wp-content"))
    |> Stream.reject(&String.contains?(&1, "wp-json"))
    |> Stream.reject(&String.contains?(&1, "wprm_print"))
    # images & other assets
    |> Stream.reject(&String.ends_with?(&1, ".jpg"))
    |> Stream.reject(&String.ends_with?(&1, ".jpeg"))
    |> Stream.reject(&String.ends_with?(&1, ".png"))
    |> Stream.reject(&String.ends_with?(&1, ".gif"))
    |> Stream.reject(&String.ends_with?(&1, ".pdf"))
    |> Stream.reject(&String.ends_with?(&1, ".xml"))
    |> Stream.reject(&String.ends_with?(&1, ".php"))
    |> Stream.reject(&String.ends_with?(&1, ".js"))
    |> Stream.reject(&String.ends_with?(&1, ".css"))
    # amp.dev
    |> Stream.reject(&String.ends_with?(&1, "amp/"))
    |> Stream.reject(&String.ends_with?(&1, "amp"))
    # RSS
    |> Stream.reject(&String.ends_with?(&1, "feed/"))
    |> Stream.reject(&String.ends_with?(&1, "feed"))
  end

  def reject_non_domain_urls(urls, seed) do
    %URI{host: seed_host} = URI.parse(seed)
    Stream.reject(urls, fn url -> URI.parse(url).host != seed_host end)
  end

  def process_relative_urls(urls, seed) do
    urls
    |> Stream.map(fn url -> to_absolute_url(url, seed) end)
    |> Stream.reject(&(&1 == ""))
  end

  defp to_absolute_url(url, seed) do
    with %URI{scheme: s, host: h, path: p} <- URI.parse(url),
         %URI{scheme: seed_scheme, host: seed_host} <- URI.parse(seed),
         scheme <- scheme(s, seed_scheme),
         {:ok, host} <- host(h, seed_host),
         path <- path(p) do
      scheme <> host <> path
    else
      _ -> ""
    end
  end

  defp scheme("https", _), do: "https://"
  defp scheme(_, s) when s != nil and s != "", do: s <> "://"
  defp scheme(_, _), do: "http://"

  defp host(h, _) when h != nil and h != "", do: {:ok, h}
  defp host(_, s) when s != nil and s != "", do: {:ok, s}
  defp host(_, _), do: {:error, "nil or empty host"}

  defp path(nil), do: "/"
  defp path(""), do: "/"
  defp path(p), do: p
end
