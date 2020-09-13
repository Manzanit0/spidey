defmodule Spidey do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias Spidey.File
  alias Spidey.Crawler

  @doc """
  Crawls a website for all the same-domain urls, returning a list with them.

  The defauilt `pool_name` is `:default`, but a custom one can be provided.

  The default filter rejects assets, Wordpress links, and others. To provide
  custom filtering make sure to implement the `Spidey.Filter` behaviour and
  provide it via the `filter` option.

  Furthermore, `crawl/3` accepts the following options:

    * `filter`: a custom url filter
    * `pool_size`: the amount of workers to crawl the website. Defaults to 20.
    * `max_overflow`: the amount of workers to overflow before queueing urls. Defaults to 5.

  ## Examples

      iex> Spidey.crawl("https://manzanit0.github.io", :crawler_pool, filter: MyCustomFilter, pool_size: 15)
      ["https://https://manzanit0.github.io/foo", "https://https://manzanit0.github.io/bar-baz/#", ...]
  """
  def crawl(url, pool_name \\ :default, opts \\ []) when is_binary(url) and is_atom(pool_name) do
    Crawler.crawl(url, pool_name, opts)
  end

  @doc "Just like `crawl/3` but saves the list of urls to file"
  def crawl_to_file(url, path, pool_name \\ :default, opts \\ [])
      when is_binary(url) and is_atom(pool_name) do
    url
    |> crawl(pool_name, opts)
    |> File.save(path)
  end
end
