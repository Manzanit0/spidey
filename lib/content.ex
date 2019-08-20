defmodule Content do
  @behaviour ContentBehaviour

  def parse_links(html) when is_binary(html) do
    html
    |> Floki.find("* a")
    |> Floki.attribute("href")
  end

  def get!(url) when is_binary(url) do
    url
    |> HTTPoison.get!()
    |> Map.get(:body)
  end
end

defmodule ContentBehaviour do
  @callback parse_links(String.t()) :: [String.t()]
  @callback get!(String.t()) :: String.t()
end
