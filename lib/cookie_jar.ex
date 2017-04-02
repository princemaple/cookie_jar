defmodule CookieJar do
  @moduledoc """
  CookieJar is here to store your cookie
  """

  use GenServer

  @doc """
  Create a new cookie jar

  ## examples

      CookieJar.start_link
      # or
      CookieJar.new
  """
  @spec start_link(keyword) :: GenServer.onstart
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  See what's in the cookie jar, the individual cookies

  ## examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.put(jar, {"name", "john doe"})
      iex> CookieJar.peek(jar)
      %{"name" => "john doe"}
  """
  @spec peek(GenServer.server) :: map
  def peek(jar) do
    GenServer.call(jar, :peek)
  end

  @doc """
  Get the cookies in Cookie format

  # examples

      CookieJar.to_string(jar)
      # or
      CookieJar.label(jar)

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.to_string(jar)
      ""
      iex> CookieJar.put(jar, {"a", 1})
      iex> CookieJar.put(jar, {"b", 2})
      iex> CookieJar.to_string(jar)
      "a=1; b=2"
  """
  @spec to_string(GenServer.server) :: String.t
  def to_string(jar) do
    GenServer.call(jar, :to_string)
  end

  @doc """
  Put cookie into a cookie jar

  # examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.put(jar, {"a", 1})
      iex> CookieJar.put(jar, {"b", 2})
      iex> CookieJar.to_string(jar)
      "a=1; b=2"
  """
  @spec put(GenServer.server, {term, term}) :: :ok
  def put(jar, cookie) do
    GenServer.cast(jar, {:put, cookie})
  end

  @doc """
  Put *new* cookie into a cookie jar

  # examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.put(jar, {"a", 1})
      iex> CookieJar.put_new(jar, {"a", 3})
      iex> CookieJar.to_string(jar)
      "a=1"
  """
  @spec put_new(GenServer.server, {term, term}) :: :ok
  def put_new(jar, cookie) do
    GenServer.cast(jar, {:put_new, cookie})
  end

  @doc """
  Pour cookies into a cookie jar

  # examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.pour(jar, %{"a" => 1, "b" => 2})
      iex> CookieJar.peek(jar)
      %{"a" => 1, "b" => 2}
  """
  @spec pour(GenServer.server, map) :: :ok
  def pour(jar, cookies) do
    GenServer.cast(jar, {:pour, cookies})
  end

  @doc """
  Destroy a cookie jar

  # examples

      CookieJar.stop(jar)
      # or
      CookieJar.smash(jar)

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.stop(jar)
      iex> Process.alive?(jar)
      false
  """
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
