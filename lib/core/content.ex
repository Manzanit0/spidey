defmodule Spidey.Core.ContentBehaviour do
  @callback parse_links(String.t()) :: [String.t()]
  @callback get!(String.t()) :: String.t()
end

defmodule Spidey.Core.Content do
  @behaviour Spidey.Core.ContentBehaviour

  def parse_links(html) when is_binary(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("*[href]")
    |> Floki.attribute("href")
  end

  def get!(url) when is_binary(url) do
    url
    |> HTTPoison.get!([], timeout: 15_000, recv_timeout: 15_000, follow_redirect: true)
    |> Map.get(:body)
  end
end
