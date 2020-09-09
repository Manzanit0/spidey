defmodule CrawlerTest do
  use ExUnit.Case, async: true

  alias Spidey.Crawler.Content
  alias Spidey.Crawler

  import Mox

  @tag :skip
  test "doesn't get urls upon invalid url" do
    Application.get_env(:spidey, :content)
    |> expect(:get!, fn _ -> raise HTTPoison.Error end)

    results = Crawler.crawl("wrong-url.com")

    assert ["wrong-url.com"] == results
  end

  @tag :skip
  test "crawls a site with depth 3" do
    html1 = """
    <html>
      <body>
        <div><a href="https://depth.com/1"></a></div>
      </body>
    </html>
    """

    html2 = """
    <html>
      <body>
        <div><a href="https://depth.com/2"></a></div>
        <div><a href="https://depth.com/1"></a></div>
      </body>
    </html>
    """

    html3 = """
    <html>
      <body>
        <a href="https://depth.com/3"></a>
        <div><a href="https://depth.com/1"></a></div>
        <div><a href="https://depth.com/2"></a></div>
        <a href="https://notvalid.depth.com/3"></a>
      </body>
    </html>
    """

    Application.get_env(:spidey, :content)
    |> expect(:get!, fn "https://depth.com" -> html1 end)
    |> expect(:get!, fn "https://depth.com/1" -> html2 end)
    |> expect(:get!, fn "https://depth.com/2" -> html3 end)
    |> expect(:get!, fn "https://depth.com/3" -> html1 end)
    |> expect(:parse_links, 4, &Content.parse_links/1)

    results = Crawler.crawl("https://depth.com")

    assert [
             "https://depth.com/3",
             "https://depth.com/2",
             "https://depth.com/1",
             "https://depth.com"
           ] == results
  end

  @tag :skip
  test "gets the urls of a website" do
    html = """
    <html>
      <body>
        <a href="https://jgarcia.blog"></a>
        <div><a href="https://jgarcia.site"></a></div>
      </body>
    </html>
    """

    Application.get_env(:spidey, :content)
    |> expect(:get!, 1, fn _ -> html end)
    |> expect(:parse_links, 1, &Content.parse_links/1)

    results = Content.scan("some.url")

    assert ["https://jgarcia.blog", "https://jgarcia.site"] == results
  end
end
