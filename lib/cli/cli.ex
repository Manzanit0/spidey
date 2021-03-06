defmodule Spidey.CLI do
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
    IO.puts("""
    usage: spidey [--help] [--site=<url>] [--save]

    The most common use case is:
      $ spidey --site https://medium.com/ --save

    It will crawl the website fetching all the urls within the same
    domain and save them to a text file in the same directory where
    the application has been executed.
    """)
  end

  def execute(site: site) do
    site
    |> Spidey.crawl()
    |> Enum.map(&IO.puts/1)
  end

  def execute(site: site, save: true) do
    Spidey.crawl_to_file(site, "results.txt")

    IO.puts("Results saved successfully!")
  end

  def execute(_) do
    IO.puts("That is not a valid spidey command. See 'spidey --help'.")
  end
end
