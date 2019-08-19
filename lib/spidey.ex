defmodule Spidey do
  @content Application.get_env(:spidey, :content)

  def crawl(urls) when is_list(urls) do
    urls
    |> Enum.map(&crawl_async/1)
    |> Enum.map(&Task.await/1)
  end

  def crawl_async(url) do
    Task.async(fn ->crawl(url) end)
  end

  def crawl(url) do
    url
    |> @content.get!()
    |> @content.parse_links()
  end
end
