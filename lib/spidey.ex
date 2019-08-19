defmodule Spidey do
  @content Application.get_env(:spidey, :content)

  def crawl(url) do
    url
    |> @content.get!()
    |> @content.parse_links()
  end
end
