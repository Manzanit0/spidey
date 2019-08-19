defmodule SpideyTest do
  use ExUnit.Case, async: true
  doctest Spidey

  @tag :callout
  test "gets the urls of a website" do
    assert length(Spidey.crawl("https://monzo.com/")) > 0
  end
end
