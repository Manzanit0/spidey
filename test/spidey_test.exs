defmodule SpideyTest do
  use ExUnit.Case, async: true

  import Mox

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
      </body>
    </html>
    """

    html3 = """
    <html>
      <body>
        <a href="https://depth.com/3"></a>
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

    results =
      "https://depth.com"
      |> Spidey.new()
      |> Spidey.crawl()

    assert [
             "https://depth.com",
             "https://depth.com/1",
             "https://depth.com/2",
             "https://depth.com/3"
           ] == results
  end

  test "gets the urls of a website" do
    setup_content_stub(1)

    results = Spidey.scan("some.url")

    assert ["https://jgarcia.blog", "https://jgarcia.site"] == results
  end

  test "filter urls whose domain doesn't match the seed's" do
    seed = "https://monzo.com/"

    scanned_urls = [
      "https://facebook.com/some-profile",
      "google.com",
      "http://monzo.com/careers",
      "http://community.monzo.com/home",
      "http://jgarcia.blog"
    ]

    filtered_urls = Spidey.filter_non_domain_urls(scanned_urls, seed)

    assert ["http://monzo.com/careers"] == filtered_urls
  end

  def setup_content_stub(executions) do
    html = """
    <html>
      <body>
        <a href="https://jgarcia.blog"></a>
        <div><a href="https://jgarcia.site"></a></div>
      </body>
    </html>
    """

    Application.get_env(:spidey, :content)
    |> expect(:get!, executions, fn _ -> html end)
    |> expect(:parse_links, executions, &Content.parse_links/1)
  end
end
