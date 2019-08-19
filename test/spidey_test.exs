defmodule SpideyTest do
  use ExUnit.Case, async: true

  import Mox

  test "gets the urls of a stubbed website" do
    setup_content_stub()

    assert ["https://jgarcia.blog", "https://jgarcia.site"] == Spidey.crawl("some.url")
  end

  def setup_content_stub do
    html = """
    <html>
      <body>
        <a href="https://jgarcia.blog"></a>
        <div><a href="https://jgarcia.site"></a></div>
      </body>
    </html>
    """

    Application.get_env(:spidey, :content)
    |> expect(:get!,fn _ -> html end)
    |> expect(:parse_links, &Content.parse_links/1)
  end
end
