defmodule Oauthex.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :oauthex,
      version: @version,
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [extras: ["README.md"], main: "readme",
             source_ref: "v#{@version}",
             source_url: "https://github.com/h1u2i3/oauthex"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {Oauthex, []},
      applications: [
       :logger,
       :httpoison
      ]
    ]
  end

  defp description do
    """
    Oauth2 client for Phoenix.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:phoenix, "~> 1.2.1"},
      {:httpoison, "~> 0.8.3"},
      {:poison, "~> 2.2.0"},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},
    ]
  end

  defp package do
    [
      name: :oauthex,
      maintainers: ["h1u2i3"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/h1u2i3/oauthex"}
    ]
  end
end
