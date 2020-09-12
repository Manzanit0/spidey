defmodule Spidey do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias Spidey.File
  alias Spidey.Crawler

  @doc """
  Crawls a website for all the same-domain urls, returning a list.

  ## Examples

      iex> Spidey.crawl("https://manzanit0.github.io", :crawler_pool, filter: MyCustomFilter, pool_size: 15)
      ["https://https://manzanit0.github.io/foo", "https://https://manzanit0.github.io/bar-baz/#", ...]
  """
  def crawl(url, pool_name \\ :default, opts \\ []) when is_binary(url) and is_atom(pool_name) do
    Crawler.crawl(url, pool_name, opts)
  end

  @doc "Crawls a website for all the sam-domain urls and Saves the list of urls to file"
  def crawl_to_file(url, pool_name \\ :default, path)
      when is_binary(url) and is_atom(pool_name) do
    url
    |> crawl(pool_name)
    |> File.save(path)
  end
end
