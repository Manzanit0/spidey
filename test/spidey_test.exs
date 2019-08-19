defmodule SpideyTest do
  use ExUnit.Case
  doctest Spidey

  test "gets the urls of a website" do
    assert length(Spidey.crawl("https://monzo.com/")) > 0
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
