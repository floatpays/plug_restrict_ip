# Plug Restrict IP

Restrict IP access to plugs. 

## Setup

Add to config/config.exs

    config :plug_restrict_ip,
        global_cidrs: [
        "4.4.4.0/24"
       ],
      cidrs: %{
        single_cidr: "0.0.0.0/0",
        multiple_cidrs: ["0.0.0.0/0", "::/0"],
        multiple_cidrs_with_keys: [
          one: "1.1.1.1/32",
          two: "2.2.2.3/32",
          two: "2.2.2.2/32"
        ]
      }
    
Then add the plug:

    plug PlugRestrictIp, allow: [:multiple_cidrs]


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `plug_restrict_ip` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plug_restrict_ip, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/plug_restrict_ip>.

