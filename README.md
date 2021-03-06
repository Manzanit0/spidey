# Spidey

<!-- MDOC !-->

A dead-simple, concurrent web crawler which focuses on ease of use and speed.

## Installation

The package can be installed by adding spidey to your list of dependencies in
mix.exs:

```elixir
def deps do
  [
    {:spidey, "~> 0.3"}
  ]
end
```

The docs can be found at https://hexdocs.pm/spidey

## Usage

Spidey has been thought with ease of usage in mind, so all you have to do to get
started is:

```elixir
iex> Spidey.crawl("https://manzanit0.github.io", :crawler_name, pool_size: 15)
[
  "https://https://manzanit0.github.io/foo",
  "https://https://manzanit0.github.io/bar-baz/#",
  ...
]
```

In a nutshell, the above line will:

1. Spin up a new supervision tree under the `Spidey` OTP Application that will
   supervise a task supervisor and the queue of URLs.
2. Create an ETS table to store crawled urls
3. Crawl the website
4. Return all the urls as a list
5. Teardown the supervision tree and the ETS table

The function is blocking, but if you were to call it asynchronously
multiple times, each invocation will spin up a new supervision trees with a
new task supervisor and a new queue.

### But why is it blocking?

The reason why it has been made blocking instead of non-blocking is because
there are already multiple libraries which do async crawling out there... and I
needed one that was blocking which allowed me to decide when to run it
synchronously and when not to.

### Specifying your own filter

Furthermore, if you would you want to specify your own filter for crawled
URLs, you can do so by implementing the `Spidey.Filter` behaviour:

```elixir
defmodule MyApp.RssFilter do
  @behaviour Spidey.Filter

  @impl true
  def filter_urls(urls, _opts) do
    urls
    |> Stream.reject(&String.ends_with?(&1, "feed/"))
    |> Stream.reject(&String.ends_with?(&1, "feed"))
  end
 end
```

And simply pass it down to the crawler as an option:

```elixir
Spidey.crawl("https://manzanit0.github.io", :crawler_name, filter: MyApp.RssFilter)
```

It's encouraged to use the `Stream` module instead of the `Enum` since the code
that handles the filtering uses streams.

## Configuration

Currently Spidey supports the following configuration:

- `:log` - the log level used when logging events with Elixir's
  Logger. If false, disables logging. Defaults to `:debug`

```elixir
config :spidey, log: :info
```

## Using the CLI

To be able to run the application make sure to have Elixir installed. Please
check the official instructions: [link](https://elixir-lang.org/install.html)

Once you have Elixir installed, to set up the application run:

```
git clone https://github.com/Manzanit0/spidey
cd spidey
mix deps.get
mix escript.build
```

To crawl websites, run the escript `./spidey`:

```
./spidey --site https://manzanit0.github.io/
```

[Escripts](https://hexdocs.pm/mix/master/Mix.Tasks.Escript.Build.html)
will run in any system which has Erlang/OTP installed, regardless
if they have Elixir or not.

### CLI options

Spidey provides two main functionalities – crawling a specific domain and saving
it to a file according to the [plain text site map protocol](https://www.sitemaps.org/protocol.html).
For the latter, simply append `--save` to the execution.
