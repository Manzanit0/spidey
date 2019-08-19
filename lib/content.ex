defmodule Content do
  def parse_links(html) do
    html
    |> Floki.find("* a")
    |> Floki.attribute("href")
  end

  def get!(url) do
    url
    |> HTTPoison.get!()
    |> Map.get(:body)
  end
end
