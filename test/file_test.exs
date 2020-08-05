defmodule FileTest do
  use ExUnit.Case, async: true

  @test_file "test_file.txt"

  setup do
    on_exit(fn ->
      File.rm!(@test_file)
    end)
  end

  test "save a list of urls in sitemap format" do
    urls = ["one.com", "two.co.uk", "three.es"]

    :ok = Spidey.Core.File.save(urls, @test_file)

    assert File.exists?(@test_file)
    assert {:ok, "one.com\ntwo.co.uk\nthree.es"} == File.read(@test_file)
  end
end
