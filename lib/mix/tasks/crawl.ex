defmodule Mix.Tasks.Crawl do
  use Mix.Task

  @shortdoc "crawls a website"
  def run(url) do
    {:ok, _started} = Application.ensure_all_started(:httpoison)
    {:ok, _started} = Application.ensure_all_started(:mochiweb)
    {:ok, _started} = Application.ensure_all_started(:html_entities)
    :ok = Application.ensure_started(:floki)

    url
    |> List.first()
    |> Spidey.new()
    |> Spidey.crawl()
    |> IO.inspect
  end
end
