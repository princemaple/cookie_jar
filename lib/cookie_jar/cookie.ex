defmodule CookieJar.Cookie do
  @moduledoc """
  Model individual Cookie as specified by the
  [MDN doc](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)
  Some of the functionalities are irrelevant so only the following attributes are kept:
  domain, include_subdomain, path, secure, expires, name and value
  """

  defstruct domain: "",
            include_subdomain: false,
            path: "",
            secure: false,
            expires: 0,
            name: "",
            value: ""

  @type t :: %__MODULE__{
          domain: String.t(),
          include_subdomain: boolean(),
          path: String.t(),
          secure: boolean(),
          expires: integer(),
          name: String.t(),
          value: String.t()
        }

  @doc """
  simple constructor
  """
  @spec new(String.t(), String.t()) :: t()
  def new(name, value), do: %__MODULE__{name: name, value: value}

  @doc """
  Return true if cookie2 is superceding cookie1. Only compare domain, path and name. 
  """
  @spec equal?(t(), t()) :: boolean()
  def equal?(cookie1, cookie2) do
    cond do
      cookie2.name != cookie1.name -> false
      cookie2.domain != cookie1.domain -> false
      cookie2.path != cookie1.path -> false
      true -> true
    end
  end

  @doc """
  parse a cookie from the Set-Cookie: value. return nil if no valid cookie found
  """
  @spec parse(String.t()) :: nil | t()
  def parse(set_cookie), do: parse(set_cookie, nil)

  @doc """
  parse a cookie from the Set-Cookie: value. return nil if no valid cookie found
  taking additional infomatio ffrom the requesting URI
  """
  @spec parse(String.t(), nil | URI.t()) :: nil | t()
  def parse(set_cookie, uri) do
    # sensible default
    {host, path, secure} =
      case uri do
        nil -> {"", "", false}
        _ -> {uri.host || "", uri.path || "", uri.scheme == "https"}
      end

    cookie =
      parse_segments(
        String.split(set_cookie, ~r";\s*"),
        %__MODULE__{domain: host, path: path}
      )

    # security check
    cond do
      cookie == nil -> nil
      # attempted to set secure cookie from http
      cookie.secure && !secure -> nil
      # attempted to set cross site cookie
      uri != nil && cookie.domain != host && cookie.domain != parent_domain(host) -> nil
      true -> cookie
    end
  end

  @doc """
  Return true if the cookie shall be sent to the uri
  """
  @spec matched?(t(), URI.t()) :: boolean()
  def matched?(cookie, uri) do
    cond do
      cookie.secure && uri.scheme != "https" -> false
      cookie.expires > 0 && cookie.expires < DateTime.to_unix(DateTime.utc_now()) -> false
      !domain_match(cookie, uri.host) -> false
      !path_match(cookie, uri.path) -> false
      true -> true
    end
  end

  @doc """
  return name=value as string
  """
  @spec to_string(t()) :: String.t()
  def to_string(cookie), do: "#{cookie.name}=#{cookie.value}"

  defp domain_match(cookie, host) do
    cond do
      cookie.domain == host ->
        true

      !cookie.include_subdomain ->
        false

      true ->
        # We stored domain without leading dot
        String.slice(host, (0 - String.length(cookie.domain) - 1)..-1) ==
          "." <> cookie.domain
    end
  end

  defp path_match(cookie, path) do
    path = path || "/"

    cond do
      cookie.path == "" ->
        true

      cookie.path == path ->
        true

      true ->
        # we store path without trailing /
        String.slice(path, 0..String.length(cookie.path)) ==
          cookie.path <> "/"
    end
  end

  defp parse_segments([], %__MODULE__{name: "", value: ""}), do: nil
  defp parse_segments([], cookie), do: cookie

  # the first segment is name=value
  defp parse_segments([head | tail], cookie = %__MODULE__{name: "", value: ""}) do
    case String.split(head, "=", parts: 2) do
      [name, value] ->
        parse_segments(tail, %{cookie | name: name, value: value})

      _ ->
        nil
    end
  end

  defp parse_segments([head | tail], cookie) do
    case String.split(head, "=", parts: 2) do
      [name, value] ->
        parse_segments(tail, update_cookie(cookie, String.downcase(name), value))

      [name] ->
        parse_segments(tail, update_cookie(cookie, String.downcase(name)))
    end
  end

  defp update_cookie(cookie, "path", path) do
    %{cookie | path: String.trim_trailing(path, "/")}
  end

  defp update_cookie(cookie, "domain", domain) do
    %{cookie | domain: String.trim_leading(domain, "."), include_subdomain: true}
  end

  defp update_cookie(cookie, "max-age", age) do
    case Integer.parse(age) do
      {seconds, ""} ->
        %{
          cookie
          | expires:
              DateTime.utc_now()
              |> DateTime.add(seconds)
              |> DateTime.to_unix()
        }

      _ ->
        cookie
    end
  end

  defp update_cookie(cookie, _, _), do: cookie

  defp update_cookie(cookie, "secure"), do: %{cookie | secure: true}
  defp update_cookie(cookie, _), do: cookie

  defp parent_domain(host) do
    case String.split(host, ".", parts: 2) do
      [_head, parent] -> parent
      _ -> nil
    end
  end
end
