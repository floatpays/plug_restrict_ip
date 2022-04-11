defmodule PlugRestrictIp.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_restrict_ip,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.12"},
      {:inet_cidr, "~> 1.0"},

      # Static Analysis
      {:credo, "~> 1.4", only: [:dev], runtime: false}
    ]
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Wilhelm H Kirschbaum"],
      licenses: [],
      links: %{}
    ]
  end

  defp description do
    "Restrict incoming requests by IP"
  end
end
