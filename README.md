# GdscDirect: discord Bot for calculate the Social Credits, handling roll-call


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gdsc_direct` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gdsc_direct, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/gdsc_direct>.

## Deploy and Running

First we need to install all the deps used in this module:
```
$ mix deps.get
```

After that we run the module for get the bot started. Make sure your fill the example config in [`config/config.exs`](https://github.com/sophiathedev/gdscdirect/blob/master/config/config.exs):
```
$ mix compile
$ mix run --no-halt
```

