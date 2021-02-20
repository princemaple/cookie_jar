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

1. Add alias (optional)

```elixir
alias CookieJar.HTTPoison, as: HTTPoison
```

2. Get a cookie jar

```elixir
{:ok, jar} = CookieJar.new
```

Alternatively, you can use a permenent cookie jar by starting one as part of your supervision tree:

```elixir
  def start(_type, _args) do
    children = [
    {CookieJar.Server, name: MyApp.CookieJar},
    ...
```

Then you can use `MyApp.CookieJar` as the application-wide jar.

3. Shove the jar into all http calls

```diff
- HTTPoison.get("https://example.com/api/call")
+ HTTPoison.get(jar, "https://example.com/api/call")
```

4. Profit (cookies imprisoned)
   All cookies from "Set-Cookie:" response headers are now stored in the jar and will be automatically sent back through "Cookie:" request headers. CookieJar respect the following attributes in the cookies:

- Domain: To limit abuses, CookieJar only allows `Domain` to be set to the current hostname of the request or its immediate parent domain.
- Path: A cookie can limit the sending back to part of the path tree in the request
- Secure: A secure cookie can only be set by https responses and used by https requests
- Max-Age: A cookie can specify its max age

All other attributes are silently ignored.

**Take a look at [the docs](https://hexdocs.pm/cookie_jar)**

- [How to directly use CookieJar](https://hexdocs.pm/cookie_jar/CookieJar.html#content)
- [HTTPoison adapter](https://hexdocs.pm/cookie_jar/CookieJar.HTTPoison.html#content)
- [HTTPotion adapter](https://hexdocs.pm/cookie_jar/CookieJar.HTTPotion.html#content)
