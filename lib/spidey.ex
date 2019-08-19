defmodule Spidey do
  def crawl(url) do
    url
    |> Content.get!()
    |> Content.parse_links()
  end
end
