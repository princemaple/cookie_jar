defmodule CookieJar.Server do
  @moduledoc """
  CookieJar server process implementation
  """

  alias CookieJar.Cookie

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:peek, from, jar), do: handle_call({:peek, nil}, from, jar)

  def handle_call({:peek, uri}, _from, jar) do
    {:reply, all_matched(jar, uri), jar}
  end

  def handle_call(:to_string, from, jar), do: handle_call({:to_string, nil}, from, jar)

  def handle_call({:to_string, uri}, _from, jar) do
    reply =
      jar
      |> all_matched(uri)
      |> Enum.sort(fn {k1, _}, {k2, _} -> k1 <= k2 end)
      |> Enum.map(fn {name, value} -> "#{name}=#{value}" end)
      |> Enum.join("; ")

    {:reply, reply, jar}
  end

  def handle_cast({:put, {key, value}}, jar) do
    {:noreply, put_cookie(jar, Cookie.new(key, value))}
  end

  def handle_cast({:put, cookie}, jar) do
    {:noreply, put_cookie(jar, cookie)}
  end

  def handle_cast({:put_new, {key, value}}, jar) do
    {:noreply, put_new_cookie(jar, Cookie.new(key, value))}
  end

  def handle_cast({:put_new, cookie}, jar) do
    {:noreply, put_new_cookie(jar, cookie)}
  end

  def handle_cast({:pour, cookies}, jar) when is_map(cookies) do
    jar =
      cookies
      |> Enum.map(fn {name, value} -> Cookie.new(name, value) end)
      |> Enum.reduce(jar, &put_cookie(&2, &1))

    {:noreply, jar}
  end

  def handle_cast({:pour, cookies}, jar) when is_list(cookies) do
    {:noreply, Enum.reduce(cookies, jar, &put_cookie(&2, &1))}
  end

  defp put_cookie(jar, cookie) do
    case Map.fetch(jar, cookie.domain) do
      :error ->
        Map.put(jar, cookie.domain, [cookie])

      {:ok, list} ->
        Map.put(jar, cookie.domain, [cookie | Enum.reject(list, &Cookie.equal?(&1, cookie))])
    end
  end

  defp put_new_cookie(jar, cookie) do
    case Map.fetch(jar, cookie.domain) do
      :error ->
        Map.put(jar, cookie.domain, [cookie])

      {:ok, list} ->
        cond do
          Enum.any?(list, &Cookie.equal?(&1, cookie)) -> jar
          true -> Map.put(jar, cookie.domain, [cookie | list])
        end
    end
  end

  # return all cookies in the nil bin as a name => value map
  defp all_matched(jar, nil) do
    jar
    |> Map.get("", [])
    |> Enum.map(fn each -> {each.name, each.value} end)
    |> Enum.into(%{})
  end

  # return all cookies the shall be returned to uri as a name => value map 
  defp all_matched(jar, uri) do
    uri
    |> all_domains()
    |> Enum.map(&Map.get(jar, &1, []))
    |> List.flatten()
    |> Enum.filter(&Cookie.matched?(&1, uri))
    |> Enum.map(fn each -> {each.name, each.value} end)
    |> Enum.into(%{})
  end

  # return domain and all parent domains in a list, most specific in the end.
  # eg: www.example.com will be: ["com", "example.com", "www.example.com"]
  defp all_domains(%URI{host: nil}), do: []
  defp all_domains(%URI{host: host}), do: all_domains([], host)

  defp all_domains(list, host) do
    case String.split(host, ".", parts: 2) do
      [_head] -> [host | list]
      [_head, tail] -> all_domains([host | list], tail)
    end
  end
end
