defmodule CookieJar do
  alias CookieJar.Cookie

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
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts \\ []), do: CookieJar.Server.start_link(opts)

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
  See what's in the cookie jar, the individual cookies available to a URI
  """
  @spec peek(GenServer.server(), String.t()) :: map
  def peek(jar, uri_str) do
    GenServer.call(jar, {:peek, URI.parse(uri_str)})
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
  Get the cookies in Cookie format for the given URI
  """
  @spec to_string(GenServer.server(), String.t()) :: String.t()
  def to_string(jar, uri_str) do
    GenServer.call(jar, {:to_string, URI.parse(uri_str)})
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
  @spec put(GenServer.server(), Cookie.t() | {term, term}) :: :ok
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
  @spec put_new(GenServer.server(), Cookie.t() | {term, term}) :: :ok
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
  @spec pour(GenServer.server(), list | map) :: :ok
  def pour(jar, cookies) do
    GenServer.cast(jar, {:pour, cookies})
  end

  @doc """
  Pour cookies into a cookie jar, using cookie strings and a uri string
  """
  @spec pour(GenServer.server(), list, String.t()) :: :ok
  def pour(jar, cookie_strs, uri_str) do
    uri = URI.parse(uri_str)

    cookies =
      cookie_strs
      |> Enum.map(&Cookie.parse(&1, uri))
      |> Enum.reject(&is_nil/1)

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
  defdelegate label(jar, uri_str), to: __MODULE__, as: :to_string
  defdelegate smash(jar), to: __MODULE__, as: :stop
end
