defmodule Spidey.Filter do
  @doc "Filters the urls"
  @callback filter_urls(urls :: [String.t()], opts :: [Keyword.t()]) :: [String.t()]

  def filter_urls(urls, filter, opts \\ []) do
    filter.filter_urls(urls, opts)
  end
end
