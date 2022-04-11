import Config

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
