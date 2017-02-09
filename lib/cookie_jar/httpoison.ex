defmodule CookieJar.HTTPoison do
  @actions_without_body ~w[get get! head head! options options! delete delete!]a
  @actions_with_body ~w[post post! put put! patch patch!]a

  for action <- @actions_without_body do
    def unquote(action)(jar, url, headers \\ [], options \\ []) do
      headers = add_jar_cookies(jar, headers)
      result = HTTPoison.unquote(action)(url, headers, options)
      update_jar_cookies(jar, result)
    end
  end

  for action <- @actions_with_body do
    def unquote(action)(jar, url, body, headers \\ [], options \\ []) do
      headers = add_jar_cookies(jar, headers)
      result = HTTPoison.unquote(action)(url, body, headers, options)
      update_jar_cookies(jar, result)
    end
  end

  defp add_jar_cookies(jar, headers) do
    jar_cookies = jar |> CookieJar.peek |> Enum.into([])

    headers
    |> Enum.into(%{})
    |> Map.update("Cookie", Enum.join(jar_cookies, "; "), fn user_cookies ->
      Enum.join([user_cookies | jar_cookies], "; ")
    end)
    |> Enum.into([])
  end

  defp update_jar_cookies(_jar, {:error, %HTTPoison.Error{} = error}), do: {:error, error}

  defp update_jar_cookies(jar, %HTTPoison.Response{headers: headers} = response) do
    do_update_jar_cookies(jar, headers)
    response
  end

  defp update_jar_cookies(jar, {:ok, %HTTPoison.Response{headers: headers} = response}) do
    do_update_jar_cookies(jar, headers)
    {:ok, response}
  end

  defp do_update_jar_cookies(jar, headers) do
    cookies = Enum.reduce(headers, %{}, fn
      {"Set-Cookie", cookie}, cookies ->
        [key_value_string | _rest] = String.split(cookie, "; ")
        [key, value] = String.split(key_value_string, "=", parts: 2)
        Map.put(cookies, key, value)
      _, cookies -> cookies
    end)
    CookieJar.pour(jar, cookies)
  end
end
