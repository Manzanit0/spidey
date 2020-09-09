defmodule Spidey do
  @moduledoc """
  Spidey is a basic web crawler which runs through all the links of a same
  domain and outputs them in a simple text sitemap format.
  """

  alias Spidey.File
  alias Spidey.Crawler

  @doc "Crawls a website for all the same-domain urls, returning a list."
  def crawl(url) when is_binary(url), do: Crawler.crawl(url)

  @doc "Crawls a website for all the sam-domain urls and Saves the list of urls to file"
  def crawl_to_file(url, path) when is_binary(url) do
    url
    |> crawl()
    |> File.save(path)
  end
end
