defmodule Spidey.Filter do
  @type filter_options :: [seed: String.t()]
  @doc "Filters the urls"
  @callback filter_urls(urls :: [String.t()], opts :: filter_options()) :: Enumerable.t()

  def filter_urls(urls, filter, opts \\ []) do
    urls
    |> filter.filter_urls(opts)
    |> Stream.uniq()
  end
end
