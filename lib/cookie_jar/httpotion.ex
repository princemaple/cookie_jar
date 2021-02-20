if Code.ensure_loaded?(HTTPotion) do
  defmodule CookieJar.HTTPotion do
    @actions ~w(
      get head options delete post put patch
      get! head! options! delete! post! put! patch!
    )a

    @moduledoc ~s"""
    Use this module instead of HTTPotion, use jar as the first argument in all
    function calls, i.e. #{inspect(@actions)}
    """

    import CookieJar.SpecUtils, only: [httpotion_spec: 1]

    for action <- @actions do
      [
        Code.eval_quoted(httpotion_spec(action), [], __ENV__),
        def unquote(action)(jar, url, options \\ []) do
          headers = add_jar_cookies(jar, options[:headers], url)
          result = HTTPotion.unquote(action)(url, Keyword.put(options, :headers, headers))
          update_jar_cookies(jar, result, url)
        end
      ]
    end

    defp add_jar_cookies(jar, nil, url), do: add_jar_cookies(jar, [], url)

    defp add_jar_cookies(jar, headers, url) do
      jar_cookies = CookieJar.label(jar, url)

      headers
      |> Enum.into(%{})
      |> Map.update(:Cookie, jar_cookies, fn user_cookies ->
        "#{user_cookies}; #{jar_cookies}"
      end)
      |> Enum.into([])
    end

    defp update_jar_cookies(jar, %HTTPotion.Response{headers: headers} = response, url) do
      do_update_jar_cookies(jar, headers, url)
      response
    end

    defp update_jar_cookies(_jar, %HTTPotion.ErrorResponse{} = error, _url), do: error

    defp do_update_jar_cookies(jar, %HTTPotion.Headers{hdrs: headers}, url) do
      response_cookies = Map.get(headers, "set-cookie", []) |> List.wrap()

      CookieJar.pour(jar, response_cookies, url)
    end
  end
end
