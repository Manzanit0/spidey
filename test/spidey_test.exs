defmodule SpideyTest do
  use ExUnit.Case, async: true

  import Mox

  test "gets the urls of a website" do
    setup_content_stub(1)

    results = Spidey.crawl("some.url")

    assert ["https://jgarcia.blog", "https://jgarcia.site"] == results
  end

  test "gets the urls of multiple websites" do
    setup_content_stub(2)

    results = Spidey.crawl(["some.url", "another.url"])

    assert [
             ["https://jgarcia.blog", "https://jgarcia.site"],
             ["https://jgarcia.blog", "https://jgarcia.site"]
           ] == results
  end

  test "filter urls whose domain doesn't match the seed's" do
    seed = "https://monzo.com/"

    fetched_urls = [
      "https://facebook.com/some-profile",
      "google.com",
      "http://monzo.com/careers",
      "http://jgarcia.blog"
    ]

    filtered_urls = Spidey.filter_non_domain_urls(seed, fetched_urls)

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
