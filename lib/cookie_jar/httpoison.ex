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
          headers = add_jar_cookies(jar, headers, url)
          result = HTTPoison.unquote(action)(url, headers, options)
          update_jar_cookies(jar, result, url)
        end
      ]
    end

    for action <- @actions_with_body do
      [
        Code.eval_quoted(httpoison_spec(action, true), [], __ENV__),
        def unquote(action)(jar, url, body, headers \\ [], options \\ []) do
          headers = add_jar_cookies(jar, headers, url)
          result = HTTPoison.unquote(action)(url, body, headers, options)
          update_jar_cookies(jar, result, url)
        end
      ]
    end

    defp add_jar_cookies(jar, headers, url) do
      jar_cookies = CookieJar.label(jar, url)

      headers
      |> Enum.into(%{})
      |> Map.update("Cookie", jar_cookies, fn user_cookies ->
        "#{user_cookies}; #{jar_cookies}"
      end)
      |> Enum.into([])
    end

    defp update_jar_cookies(_jar, {:error, %HTTPoison.Error{} = error}, _url), do: {:error, error}

    defp update_jar_cookies(jar, %HTTPoison.Response{headers: headers} = response, url) do
      do_update_jar_cookies(jar, headers, url)
      response
    end

    defp update_jar_cookies(jar, {:ok, %HTTPoison.Response{headers: headers} = response}, url) do
      do_update_jar_cookies(jar, headers, url)
      {:ok, response}
    end

    defp do_update_jar_cookies(jar, headers, url) do
      cookies =
        Enum.flat_map(headers, fn {key, value} ->
          case String.downcase(key) do
            "set-cookie" -> [value]
            _ -> []
          end
        end)

      CookieJar.pour(jar, cookies, url)
    end
  end
end
