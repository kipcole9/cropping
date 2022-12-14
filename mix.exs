defmodule Cropping.MixProject do
  use Mix.Project

  def project do
    [
      app: :cropping,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
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
      {:nimble_csv, "~> 1.2"},
      {:image, github: "kipcole9/image", branch: "draw"}
    ]
  end
end
