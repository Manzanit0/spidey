# Spidey

Basic web crawler written in Elixir

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
