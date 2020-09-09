# Spidey

[![Build Status](https://travis-ci.org/Manzanit0/spidey.svg?branch=master)](https://travis-ci.org/Manzanit0/spidey)

Spidey is a basic web crawler written in Elixir which runs through all the links
of a same domain and outputs them in a simple text sitemap format.

![Terminal output example](/terminal_output.png)

## Getting started 🛠

To be able to run the application make sure to have Elixir installed.
Please check the official instructions: [link](https://elixir-lang.org/install.html)

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

## CLI options

Spidey provides two main functionalities – crawling a specific domain and
saving it to a file according to the [plain text site map protocol](https://www.sitemaps.org/protocol.html). For the latter, simply append `--save` to the execution.
