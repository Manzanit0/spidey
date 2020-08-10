defmodule Spidey.Core.Filters do
  def strip_query_params(urls) do
    Enum.map(urls, fn s -> String.split(s, "?") |> List.first() end)
  end

  def strip_trailing_slashes(urls) do
    Enum.map(urls, fn s -> String.replace_trailing(s, "/", "") end)
  end

  def reject_invalid_urls(urls) do
    urls
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
  end

  def reject_static_resources(urls) do
    urls
    # All WordPress static content
    |> Enum.reject(&String.contains?(&1, "wp-content"))
    # images & other assets
    |> Enum.reject(&String.ends_with?(&1, ".jpg"))
    |> Enum.reject(&String.ends_with?(&1, ".jpeg"))
    |> Enum.reject(&String.ends_with?(&1, ".png"))
    |> Enum.reject(&String.ends_with?(&1, ".gif"))
    |> Enum.reject(&String.ends_with?(&1, ".pdf"))
    |> Enum.reject(&String.ends_with?(&1, ".xml"))
    |> Enum.reject(&String.ends_with?(&1, ".php"))
    |> Enum.reject(&String.ends_with?(&1, ".js"))
    |> Enum.reject(&String.ends_with?(&1, ".css"))
    # amp.dev
    |> Enum.reject(&String.ends_with?(&1, "amp/"))
    |> Enum.reject(&String.ends_with?(&1, "amp"))
    # RSS
    |> Enum.reject(&String.ends_with?(&1, "feed/"))
    |> Enum.reject(&String.ends_with?(&1, "feed"))
  end

  def reject_non_domain_urls(urls, seed) do
    %URI{host: seed_host} = URI.parse(seed)
    Enum.reject(urls, fn url -> URI.parse(url).host != seed_host end)
  end

  def reject_already_scanned_urls(urls, scanned) do
    Enum.reject(urls, fn x -> Enum.member?(scanned, x) end)
  end

  def process_relative_urls(urls, seed) do
    urls
    |> Enum.map(fn url -> to_absolute_url(url, seed) end)
    |> Enum.reject(&(&1 == ""))
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
