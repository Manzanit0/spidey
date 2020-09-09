defmodule Spidey.Crawler.ContentBehaviour do
  @callback parse_links(String.t()) :: [String.t()]
  @callback get!(String.t()) :: String.t()
end

defmodule Spidey.Crawler.Content do
  @behaviour Spidey.Crawler.ContentBehaviour

  def scan(url) when is_binary(url) do
    try do
      url
      |> get!()
      |> parse_links()
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

  @impl true
  def parse_links(html) when is_binary(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("*[href]")
    |> Floki.attribute("href")
  end

  @impl true
  def get!(url) when is_binary(url) do
    url
    |> HTTPoison.get!([],
      timeout: 15_000,
      recv_timeout: 15_000,
      follow_redirect: true,
      hackney: [pool: :default]
    )
    |> Map.get(:body)
  end
end