defmodule Taptempo.MixProject do
  use Mix.Project

  def project do
    [
      app: :taptempo,
      version: "0.1.0",
      elixir: "~> 1.6",
      escript: escript_config(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end


  def application do
    [
      extra_applications: [:logger]
    ]
  end


  defp deps do
    []
  end

  
  defp escript_config do
    [
      main_module: Taptempo
    ]
  end
end
