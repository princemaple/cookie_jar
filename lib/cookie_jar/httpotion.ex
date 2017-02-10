defmodule CookieJar.HTTPotion do
  @actions_without_body ~w[get get! head head! options options! delete delete!]a
  @actions_with_body ~w[post post! put put! patch patch!]a

  for action <- @actions_without_body do
    def unquote(action)(jar, url, options \\ []) do
      headers = add_jar_cookies(jar, options[:headers])
      result = HTTPotion.unquote(action)(url, Keyword.put(options, :headers, headers))
      update_jar_cookies(jar, result)
    end
  end

  for action <- @actions_with_body do
    def unquote(action)(jar, url, options \\ []) do
      headers = add_jar_cookies(jar, options[:headers])
      result = HTTPotion.unquote(action)(url, Keyword.put(options, :headers, headers))
      update_jar_cookies(jar, result)
    end
  end

  defp add_jar_cookies(jar, nil), do: add_jar_cookies(jar, [])
  defp add_jar_cookies(jar, headers) do
    jar_cookies = CookieJar.label(jar)

    headers
    |> Enum.into(%{})
    |> Map.update(:"Cookie", jar_cookies, fn user_cookies ->
      "#{user_cookies}; #{jar_cookies}"
    end)
    |> Enum.into([])
  end

  defp update_jar_cookies(jar, %HTTPotion.Response{headers: headers} = response) do
    do_update_jar_cookies(jar, headers)
    response
  end

  defp update_jar_cookies(_jar, %HTTPotion.ErrorResponse{} = error), do: error

  defp do_update_jar_cookies(jar, %HTTPotion.Headers{hdrs: headers}) do
    response_cookies = Map.get(headers, "set-cookie", []) |> List.wrap

    cookies = Enum.reduce(response_cookies, %{}, fn cookie, cookies ->
      [key_value_string | _rest] = String.split(cookie, "; ")
      [key, value] = String.split(key_value_string, "=", parts: 2)
      Map.put(cookies, key, value)
    end)

    CookieJar.pour(jar, cookies)
  end
end
