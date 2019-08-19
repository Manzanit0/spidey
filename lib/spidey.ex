defmodule Spidey do
  def crawl(urls) when is_list(urls) do
    Enum.each(urls, &crawl/1)
  end

  def crawl(url) do
    url
    |> fetch_website_content()
    |> parse_links()
    # |> Enum.map(fn url -> HTTPoison.get!(url) end)
  end

  def parse_links(html) do
    html
    |> Floki.find("* a")
    |> Floki.attribute("href")
  end

  def fetch_website_content(url) do
    url
    |> HTTPoison.get!()
    |> Map.get(:body)
  end
end
