defmodule Spidey do
  @content Application.get_env(:spidey, :content)

  def crawl(urls) when is_list(urls) do
    urls
    |> Enum.map(&crawl_async/1)
    |> Enum.map(&Task.await/1)
  end

  def crawl(url) do
    url
    |> @content.get!()
    |> @content.parse_links()
  end

  def crawl_async(url) do
    Task.async(fn ->crawl(url) end)
  end

  def filter_non_domain_urls(seed, urls) do
    %URI{host: seed_host} = URI.parse(seed)
    Enum.filter(urls, fn url -> URI.parse(url).host == seed_host end)
  end
end
