defmodule CookieJar do
  @moduledoc """
  CookieJar is here to store your cookie
  """

  use GenServer

  @spec start_link(keyword) :: GenServer.onstart
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec peek(GenServer.server) :: map
  def peek(jar) do
    GenServer.call(jar, :peek)
  end

  @spec to_string(GenServer.server) :: String.t
  def to_string(jar) do
    GenServer.call(jar, :to_string)
  end

  @spec put(GenServer.server, {term, term}) :: :ok
  def put(jar, cookie) do
    GenServer.cast(jar, {:put, cookie})
  end

  @spec put_new(GenServer.server, {term, term}) :: :ok
  def put_new(jar, cookie) do
    GenServer.cast(jar, {:put_new, cookie})
  end

  @spec pour(GenServer.server, map) :: :ok
  def pour(jar, cookies) do
    GenServer.cast(jar, {:pour, cookies})
  end

  @spec stop(GenServer.server) :: :ok
  def stop(jar) do
    GenServer.stop(jar)
  end

  defdelegate new(opts \\ []), to: __MODULE__, as: :start_link
  defdelegate label(jar), to: __MODULE__, as: :to_string
  defdelegate smash(jar), to: __MODULE__, as: :stop

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
