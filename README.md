# CookieJar

[![hex.pm version](https://img.shields.io/hexpm/v/cookie_jar.svg?style=flat)](https://hex.pm/packages/cookie_jar)
[![API Docs](https://img.shields.io/badge/api-docs-blue.svg?style=flat)](https://hexdocs.pm/cookie_jar/)

![COOKIE JAR](https://cloud.githubusercontent.com/assets/1329716/22807691/5fe454d6-ef7c-11e6-8e0b-30aca685c83a.jpg)

## Installation

The package can be installed
by adding `cookie_jar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:cookie_jar, "~> 1.0"}]
end
```

## Usage

1. Add alias
```elixir
alias CookieJar.HTTPoison, as: HTTPoison
```

2. Get a cookie jar
```elixir
jar = CookieJar.new
```

3. Shove the jar into all http calls
```diff
- HTTPoison.get("https://example.com/api/call")
+ HTTPoison.get(jar, "https://example.com/api/call")
```

4. Profit (cookies imprisoned)

**Take a look at [the docs](https://hexdocs.pm/cookie_jar)**
- [How to directly use CookieJar](https://hexdocs.pm/cookie_jar/CookieJar.html#content)
- [HTTPoison adapter](https://hexdocs.pm/cookie_jar/CookieJar.HTTPoison.html#content)
- [HTTPotion adapter](https://hexdocs.pm/cookie_jar/CookieJar.HTTPotion.html#content)
