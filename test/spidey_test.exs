defmodule SpideyTest do
  use ExUnit.Case
  doctest Spidey

  test "gets the urls of a website" do
    assert length(Spidey.crawl("https://monzo.com/")) > 0
  end
end
