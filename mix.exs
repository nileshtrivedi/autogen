defmodule Autogen.MixProject do
  use Mix.Project

  def project do
    [
      app: :autogen,
      description: "Elixir port of Microsoft's multi-agent AI framework Autogen",
      package: package(),
      version: "0.3.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/nileshtrivedi/autogen"
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
      {:openai, "~> 0.6.1"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:req, "~> 0.5.0"},
      {:ollama, "~> 0.6.2"},
      {:langchain, "~> 0.3.0-rc.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "autogen",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nileshtrivedi/autogen"}
    ]
  end
end
