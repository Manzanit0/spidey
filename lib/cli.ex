defmodule CLI do
  alias Core.Spidey

  def main(args) do
    args
    |> OptionParser.parse(strict: [site: :string])
    |> elem(0)
    |> Keyword.get(:site)
    |> Spidey.new()
    |> Spidey.crawl()
    |> Enum.map(&IO.inspect/1)
  end
end
