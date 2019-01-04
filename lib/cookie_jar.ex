defmodule CookieJar do
  @moduledoc """
  CookieJar is here to store your cookie
  """

  @doc """
  Create a new cookie jar

  ## Examples

      CookieJar.start_link
      # or
      CookieJar.new
  """
  @spec start_link(keyword) :: GenServer.onstart()
  def start_link(opts \\ []) do
    GenServer.start_link(CookieJar.Server, :ok, opts)
  end

  @doc """
  See what's in the cookie jar, the individual cookies

  ## Examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.put(jar, {"name", "john doe"})
      iex> CookieJar.peek(jar)
      %{"name" => "john doe"}
  """
  @spec peek(GenServer.server()) :: map
  def peek(jar) do
    GenServer.call(jar, :peek)
  end

  @doc """
  Get the cookies in Cookie format

  ## Examples

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
  @spec to_string(GenServer.server()) :: String.t()
  def to_string(jar) do
    GenServer.call(jar, :to_string)
  end

  @doc """
  Put cookie into a cookie jar

  ## Examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.put(jar, {"a", 1})
      iex> CookieJar.put(jar, {"b", 2})
      iex> CookieJar.to_string(jar)
      "a=1; b=2"
  """
  @spec put(GenServer.server(), {term, term}) :: :ok
  def put(jar, cookie) do
    GenServer.cast(jar, {:put, cookie})
  end

  @doc """
  Put *new* cookie into a cookie jar

  ## Examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.put(jar, {"a", 1})
      iex> CookieJar.put_new(jar, {"a", 3})
      iex> CookieJar.to_string(jar)
      "a=1"
  """
  @spec put_new(GenServer.server(), {term, term}) :: :ok
  def put_new(jar, cookie) do
    GenServer.cast(jar, {:put_new, cookie})
  end

  @doc """
  Pour cookies into a cookie jar

  ## Examples

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.peek(jar)
      %{}
      iex> CookieJar.pour(jar, %{"a" => 1, "b" => 2})
      iex> CookieJar.peek(jar)
      %{"a" => 1, "b" => 2}
  """
  @spec pour(GenServer.server(), map) :: :ok
  def pour(jar, cookies) do
    GenServer.cast(jar, {:pour, cookies})
  end

  @doc """
  Destroy a cookie jar

  ## Examples

      CookieJar.stop(jar)
      # or
      CookieJar.smash(jar)

      iex> {:ok, jar} = CookieJar.new
      iex> CookieJar.stop(jar)
      iex> Process.alive?(jar)
      false
  """
  @spec stop(GenServer.server()) :: :ok
  def stop(jar) do
    GenServer.stop(jar)
  end

  defdelegate new(opts \\ []), to: __MODULE__, as: :start_link
  defdelegate label(jar), to: __MODULE__, as: :to_string
  defdelegate smash(jar), to: __MODULE__, as: :stop
end
