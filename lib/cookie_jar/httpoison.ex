if Code.ensure_loaded?(HTTPoison) do
  defmodule CookieJar.HTTPoison do
    @actions_without_body ~w[get get! head head! options options! delete delete!]a
    @actions_with_body ~w[post post! put put! patch patch!]a

    @moduledoc ~s"""
    Use this module instead of HTTPoison, use jar as the first argument in all
    function calls, i.e. #{inspect(@actions_without_body ++ @actions_with_body)}
    """

    import CookieJar.SpecUtils, only: [httpoison_spec: 2]

    for action <- @actions_without_body do
      [
        Code.eval_quoted(httpoison_spec(action, false), [], __ENV__),
        def unquote(action)(jar, url, headers \\ [], options \\ []) do
          headers = add_jar_cookies(jar, headers)
          result = HTTPoison.unquote(action)(url, headers, options)
          update_jar_cookies(jar, result)
        end
      ]
    end

    for action <- @actions_with_body do
      [
        Code.eval_quoted(httpoison_spec(action, true), [], __ENV__),
        def unquote(action)(jar, url, body, headers \\ [], options \\ []) do
          headers = add_jar_cookies(jar, headers)
          result = HTTPoison.unquote(action)(url, body, headers, options)
          update_jar_cookies(jar, result)
        end
      ]
    end

    defp add_jar_cookies(jar, headers) do
      jar_cookies = CookieJar.label(jar)

      headers
      |> Enum.into(%{})
      |> Map.update("Cookie", jar_cookies, fn user_cookies ->
        "#{user_cookies}; #{jar_cookies}"
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
      cookies =
        Enum.reduce(headers, %{}, fn {key, value}, cookies ->
          case String.downcase(key) do
            "set-cookie" ->
              [key_value_string | _rest] = String.split(value, "; ")
              [key, value] = String.split(key_value_string, "=", parts: 2)
              Map.put(cookies, key, value)

            _ ->
              cookies
          end
        end)

      CookieJar.pour(jar, cookies)
    end
  end
end
