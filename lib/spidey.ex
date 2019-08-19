defmodule Spidey do
  def crawl(urls) when is_list(urls) do
    Enum.each(urls, &crawl/1)
  end

  def crawl(url) do
    url
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Floki.find("* a")
    |> Floki.attribute("href")
    # |> Enum.map(fn url -> HTTPoison.get!(url) end)
  end
end
