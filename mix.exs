defmodule CookieJar.Mixfile do
  use Mix.Project

  def project do
    [app: :cookie_jar,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:httpoison, "~> 0.11", optional: true},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [description: "CookieJar stores your cookies and applies them to future requests",
     licenses: ["MIT"],
     maintainers: ["Po Chen"],
     links: %{"GitHub": "https://github.com/princemaple/cookie_jar"}]
  end
end
