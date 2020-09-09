defmodule ContentTest do
  use ExUnit.Case, async: true

  alias Spidey.Crawler.Content

  @tag :callout
  test "fetches the content of a website" do
    content = Content.get!("https://monzo.com/")

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

    assert ["https://jgarcia.blog", "https://jgarcia.site"] == Content.parse_links(html)
  end
end
