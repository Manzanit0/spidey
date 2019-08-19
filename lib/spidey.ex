defmodule Spidey do
  @content Application.get_env(:spidey, :content)

  def scan(url) do
    url
    |> @content.get!()
    |> @content.parse_links()
  end

  def scan_async(url) do
    Task.async(fn ->crawl(url) end)
  end

  def filter_non_domain_urls(urls, seed) do
    %URI{host: seed_host} = URI.parse(seed)
    Enum.filter(urls, fn url -> URI.parse(url).host == seed_host end)
  end
end
