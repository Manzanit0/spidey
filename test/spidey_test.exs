defmodule SpideyTest do
  use ExUnit.Case, async: true
  doctest Spidey

  @tag :callout
  test "gets the urls of a website" do
    assert length(Spidey.crawl("https://monzo.com/")) > 0
  end

  @tag :callout
  test "fetches the content of a website" do
    content = Spidey.fetch_website_content("https://monzo.com/")

    assert is_binary(content)
    assert String.contains?(content, "</html>")
  end

  test "parses the links of a website" do
    html = """
    <html>
      <body>
        <a href="https://jgarcia.blog"></a>
        <div><a href="https://jgarcia.site"></a></div>
      </body>
    </html>
    """

    assert ["https://jgarcia.blog", "https://jgarcia.site"] == Spidey.parse_links(html)
  end
end
