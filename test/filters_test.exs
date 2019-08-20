defmodule FiltersTest do
  use ExUnit.Case, async: true

  test "filter urls whose domain doesn't match the seed's" do
    seed = "https://monzo.com/"

    scanned_urls = [
      "https://facebook.com/some-profile",
      "google.com",
      "http://monzo.com/careers",
      "http://community.monzo.com/home",
      "http://jgarcia.blog"
    ]

    filtered_urls = Filters.non_domain_urls(scanned_urls, seed)

    assert ["http://monzo.com/careers"] == filtered_urls
  end

  test "filter already scanned urls" do
    urls = [
      "http://monzo.com/careers",
      "http://monzo.com/blog"
    ]

    scanned_urls = [
      "http://monzo.com/home",
      "http://monzo.com/blog"
    ]

    filtered_urls = Filters.already_scanned_urls(urls, scanned_urls)

    assert ["http://monzo.com/careers"] == filtered_urls
  end

  test "adds the host to relative urls using the seed's http scheme" do
    urls = [
      "https://mysomething.url",
      "/legal/1",
      "/home",
      "/services"
    ]

    processed_urls = Filters.process_relative_urls(urls, "http://jgarcia.com")

    assert [
             "https://mysomething.url/",
             "http://jgarcia.com/legal/1",
             "http://jgarcia.com/home",
             "http://jgarcia.com/services"
           ] == processed_urls
  end

  test "adds the host to relative urls using the seed's https scheme" do
    urls = [
      "https://mysomething.url",
      "/legal/1",
      "/home",
      "/services"
    ]

    processed_urls = Filters.process_relative_urls(urls, "https://jgarcia.com")

    assert [
             "https://mysomething.url/",
             "https://jgarcia.com/legal/1",
             "https://jgarcia.com/home",
             "https://jgarcia.com/services"
           ] == processed_urls
  end
end
