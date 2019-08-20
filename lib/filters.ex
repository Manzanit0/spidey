defmodule Filters do
  def non_domain_urls(urls, seed) do
    %URI{host: seed_host} = URI.parse(seed)
    Enum.filter(urls, fn url -> URI.parse(url).host == seed_host end)
  end

  def already_scanned_urls(urls, scanned) do
    Enum.filter(urls, fn x -> !Enum.member?(scanned, x) end)
  end

  def process_relative_urls(urls, seed) do
    Enum.map(urls, fn url -> to_absolute_url(url, seed) end)
  end

  defp to_absolute_url(url, seed) do
    with %URI{scheme: s, host: h, path: p} <- URI.parse(url),
         %URI{scheme: seed_scheme, host: seed_host} <- URI.parse(seed),
         scheme <- scheme(s, seed_scheme),
         host <- host(h, seed_host),
         path <- path(p) do
      scheme <> host <> path
    else
      :error -> ""
    end
  end

  defp scheme("https", _), do: "https://"
  defp scheme(_, s) when s != nil and s != "", do: s <> "://"
  defp scheme(_, _), do: "http://"

  defp host(h, _) when h != nil and h != "", do: h
  defp host(_, s) when s != nil and s != "", do: s
  defp host(_, _), do: {:error, "nil or empty host"}

  defp path(nil), do: "/"
  defp path(""), do: "/"
  defp path(p), do: p
end
