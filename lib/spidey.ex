defmodule Spidey do
  @moduledoc """
  Spidey is a basic web crawler which runs through all the links of a same
  domain and outputs them in a simple text sitemap format.
  """

  alias Spidey.File
  alias Spidey.Crawler
  alias Spidey.PoolManager

  @doc """
  Crawls a website for all the same-domain urls, returning a list.

  iex> Spidey.crawl("https://manzanit0.github.io", :crawler_pool, filter: MyCustomFilter, pool_size: 15)
  [
    "https://https://manzanit0.github.io/foo",
    "https://https://manzanit0.github.io/bar-baz/#",
    ...
  ]
  """
  def crawl(url, pool_name \\ :default, opts \\ []) when is_binary(url) and is_atom(pool_name) do
    PoolManager.start_child(pool_name, opts)

    try do
      Crawler.crawl(url, pool_name)
    after
      PoolManager.terminate_child(pool_name)
    end
  end

  @doc "Crawls a website for all the sam-domain urls and Saves the list of urls to file"
  def crawl_to_file(url, pool_name \\ :default, path)
      when is_binary(url) and is_atom(pool_name) do
    url
    |> crawl(pool_name)
    |> File.save(path)
  end
end
