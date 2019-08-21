defmodule CLI do
  alias Core.Spidey

  def main(args) do
    args
    |> parse_params()
    |> execute()
  end

  defp parse_params(args) do
    args
    |> OptionParser.parse(strict: [site: :string, save: :boolean, help: :boolean])
    |> elem(0)
  end

  def execute(help: true) do
    IO.puts("The two available parameters are --help and --site")
  end

  def execute(site: site) do
    site
    |> Spidey.new()
    |> Spidey.crawl()
  end

  def execute(site: site, save: true) do
    execute(site: site)
    |> Core.File.save("results.txt")

    IO.puts("Results saved successfully!")
  end

  def execute(_) do
    IO.puts("That is not a valid spidey command. See 'spidey --help'.")
  end
end
