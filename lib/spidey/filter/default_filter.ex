defmodule Spidey.Filter.DefaultFilter do
  @moduledoc """
  An implementation of the `Spidey.Filter` behaviour which:

  1. Transforms relative urls to absolute urls
  2. Strips the query parameters of all urls, to simplify unicity.
  3. Strips the trailing slashes of all urls.
  4. Rejects all urls from a different domain than the seed's.
  5. Rejects invalid urls
  6. Reject static resources based on different criteria such as wordpress paths and file type.

  This behaviour requires the option `:seed`.
  """
  @behaviour Spidey.Filter

  @impl true
  @spec filter_urls(list(String.t()), Spidey.Filter.filter_options()) :: Enumerable.t()
  def filter_urls(urls, opts) do
    seed = get_seed_option(opts)

    urls
    |> process_relative_urls(seed)
    |> strip_query_params()
    |> strip_trailing_slashes()
    |> reject_non_domain_urls(seed)
    |> reject_invalid_urls()
    |> reject_static_resources()
  end

  @spec strip_query_params(Enumerable.t()) :: Enumerable.t()
  def strip_query_params(urls) do
    Stream.map(urls, fn s -> String.split(s, "?") |> List.first() end)
  end

  @spec strip_trailing_slashes(Enumerable.t()) :: Enumerable.t()
  def strip_trailing_slashes(urls) do
    Stream.map(urls, fn s -> String.replace_trailing(s, "/", "") end)
  end

  @spec reject_invalid_urls(Enumerable.t()) :: Enumerable.t()
  def reject_invalid_urls(urls) do
    urls
    |> Stream.reject(&is_nil/1)
    |> Stream.reject(&(&1 == ""))
  end

  @spec reject_static_resources(Enumerable.t()) :: Enumerable.t()
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

  @spec reject_non_domain_urls(Enumerable.t(), String.t()) :: Enumerable.t()
  def reject_non_domain_urls(urls, seed) do
    %URI{host: seed_host} = URI.parse(seed)
    Stream.reject(urls, fn url -> URI.parse(url).host != seed_host end)
  end

  @spec process_relative_urls(Enumerable.t(), String.t()) :: Enumerable.t()
  def process_relative_urls(urls, seed) do
    urls
    |> Stream.map(fn url -> to_absolute_url(url, seed) end)
    |> Stream.reject(&(&1 == ""))
  end

  ## Private.

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

  defp get_seed_option(opts) do
    case Keyword.get(opts, :seed) do
      seed when is_binary(seed) ->
        seed

      _ ->
        raise """
        The `:seed` option is compulsary for the Spidey.Filter.DefaultFilter
        to work. Make sure that it's passed with the options and that it is a
        string.
        """
    end
  end
end
