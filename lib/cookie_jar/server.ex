defmodule CookieJar.Server do
  @moduledoc """
  CookieJar server process implementation
  """

  use GenServer

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:peek, _from, jar) do
    {:reply, jar, jar}
  end

  def handle_call(:to_string, _from, jar) do
    reply =
      jar
      |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
      |> Enum.join("; ")

    {:reply, reply, jar}
  end

  def handle_cast({:put, {key, value}}, jar) do
    {:noreply, Map.put(jar, key, value)}
  end

  def handle_cast({:put_new, {key, value}}, jar) do
    {:noreply, Map.put_new(jar, key, value)}
  end

  def handle_cast({:pour, cookies}, jar) do
    {:noreply, Map.merge(jar, cookies)}
  end
end
