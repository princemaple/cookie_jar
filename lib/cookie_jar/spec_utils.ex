defmodule CookieJar.SpecUtils do
  def httpoison_spec(action, body) do
    parameters =
      if body do
        quote do
          [GenServer.server(), String.t(), any, Keyword.t(), Keyword.t()]
        end
      else
        quote do
          [GenServer.server(), String.t(), Keyword.t(), Keyword.t()]
        end
      end

    return_type =
      if action |> Atom.to_string() |> String.ends_with?("!") do
        quote do
          HTTPoison.Response.t()
          | HTTPoison.AsyncResponse.t()
          | no_return
        end
      else
        quote do
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
        end
      end

    quote do
      @spec unquote(action)(unquote_splicing(parameters)) :: unquote(return_type)
    end
  end

  def httpotion_spec(action) do
    return_type =
      if action |> Atom.to_string() |> String.ends_with?("!") do
        quote do
          HTTPotion.http_result_bang()
        end
      else
        quote do
          HTTPotion.http_result()
        end
      end

    quote do
      @spec unquote(action)(GenServer.server(), String.t(), Keyword.t()) :: unquote(return_type)
    end
  end
end
