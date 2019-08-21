defmodule Core.ContentBehaviour do
  @callback parse_links(String.t()) :: [String.t()]
  @callback get!(String.t()) :: String.t()
end

defmodule Core.Content do
  @behaviour Core.ContentBehaviour

  def parse_links(html) when is_binary(html) do
    html
    |> Floki.find("* a")
    |> Floki.attribute("href")
  end

  def get!(url) when is_binary(url) do
    url
    |> HTTPoison.get!([], timeout: 15_000, recv_timeout: 15_000)
    |> Map.get(:body)
  end
end
