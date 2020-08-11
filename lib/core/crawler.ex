defmodule Spidey.Core.Crawler do
  defmodule CrawlResult do
    defstruct [:pending, :seed]
  end

  alias Spidey.Core.Filters
  alias Spidey.Core.Queue
  alias Spidey.Core.UrlStore

  @content Application.get_env(:spidey, :content)

  def new(url) do
    UrlStore.add(url)

    %CrawlResult{seed: url, pending: [url]}
  end

  def crawl(%CrawlResult{pending: []}), do: UrlStore.retrieve_all()

  def crawl(%CrawlResult{} = cr) do
    t0 = DateTime.utc_now()

    urls = cr.pending |> scan_async()

    t1 = DateTime.utc_now()
    IO.puts("Fetching content took #{diff(t0, t1)} ms")

    urls
    |> Filters.process_relative_urls(cr.seed)
    |> Filters.strip_query_params()
    |> Filters.strip_trailing_slashes()
    |> Enum.reject(&UrlStore.exists?/1)
    |> Filters.reject_non_domain_urls(cr.seed)
    |> Filters.reject_invalid_urls()
    |> Filters.reject_static_resources()
    |> Enum.uniq()
    |> Enum.map(&push_to_stores/1)

    t2 = DateTime.utc_now()
    IO.puts("Processing URLs took #{diff(t1, t2)} ms")

    pending = Queue.take(50)

    t3 = DateTime.utc_now()
    IO.puts("Dequeueing 50 URLs took #{diff(t2, t3)} ms\n")

    crawl(%CrawlResult{cr | pending: pending})
  end

  def scan(url) when is_binary(url) do
    try do
      url
      |> @content.get!()
      |> @content.parse_links()
    rescue
      # Timeout, wrong url, etc.
      e in HTTPoison.Error ->
        IO.inspect(e, label: :url_scan_error)
        []

      # non-html format
      e in CaseClauseError ->
        IO.inspect(e, label: :url_scan_error)
        []
    end
  end

  def scan_async([]), do: []

  def scan_async(urls) when is_list(urls) do
    urls
    |> Enum.map(fn url -> Task.async(fn -> scan(url) end) end)
    |> Enum.map(fn t -> Task.await(t, 30_000) end)
    |> List.flatten()
  end

  defp push_to_stores(url) do
    Queue.push(url)
    UrlStore.add(url)
  end

  @doc """
  Simple diffing function to time short snippets of code using
  DateTime.utc_now/0.

  Take into account that it's just to get ballpark numbers. The approach is
  inherently broken.

  ## Example

  iex> t0 = DateTime.utc_now()
  iex> t1 = DateTime.utc_now()
  iex> diff(t0, t1)
  0.02
  """
  def diff(%DateTime{} = t0, %DateTime{} = t1) do
    minutes = t1.minute - t0.minute
    seconds = t1.second + minutes * 60 - t0.second
    microseconds = elem(t1.microsecond, 0) + seconds * 1_000_000 - elem(t0.microsecond, 0)

    microseconds / 1_000
  end
end
