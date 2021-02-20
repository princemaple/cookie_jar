defmodule CookieTest do
  use ExUnit.Case
  alias CookieJar.Cookie

  test "simple cookie" do
    assert %Cookie{
             name: "yummy_cookie",
             value: "choco",
             domain: "",
             path: "",
             secure: false,
             include_subdomain: true
           } = Cookie.parse("yummy_cookie=choco")
  end

  test "cookie with domain" do
    assert %Cookie{
             name: "yummy_cookie",
             value: "choco",
             domain: "example.com",
             path: "",
             secure: false,
             include_subdomain: false
           } =
             Cookie.parse(
               "yummy_cookie=choco",
               URI.parse("http://example.com")
             )
  end

  test "https cookie" do
    assert %Cookie{
             name: "yummy_cookie",
             value: "choco",
             domain: "example.com",
             path: "/whatever",
             secure: true,
             include_subdomain: false
           } =
             Cookie.parse(
               "yummy_cookie=choco; Secure",
               URI.parse("https://example.com/whatever")
             )
  end

  test "http cookie drop secure" do
    assert nil ==
             Cookie.parse(
               "yummy_cookie=choco; Secure",
               URI.parse("http://example.com")
             )
  end

  test "simple match" do
    cookie =
      Cookie.parse(
        "yummy_cookie=choco; Secure",
        URI.parse("https://example.com/whatever")
      )

    assert Cookie.matched?(cookie, URI.parse("https://example.com/whatever"))
    refute Cookie.matched?(cookie, URI.parse("http://example.com/whatever"))
  end

  test "wildcard domain" do
    cookie =
      Cookie.parse(
        "yummy_cookie=choco; Secure; Domain=example.com; Path=/",
        URI.parse("https://example.com/whatever")
      )

    assert Cookie.matched?(cookie, URI.parse("https://example.com/"))
    assert Cookie.matched?(cookie, URI.parse("https://sub.example.com/"))
    refute Cookie.matched?(cookie, URI.parse("https://sub.example2.com/"))
  end

  test "mixed case" do
    cookie =
      Cookie.parse(
        "yummy_cookie=choco; secure; Domain=example.com; path=/",
        URI.parse("https://example.com/whatever")
      )

    assert Cookie.matched?(cookie, URI.parse("https://example.com/"))
    assert Cookie.matched?(cookie, URI.parse("https://sub.example.com/"))
    refute Cookie.matched?(cookie, URI.parse("https://sub.example2.com/"))
  end

  test "match on path" do
    cookie =
      Cookie.parse(
        "yummy_cookie=choco; Secure; Domain=example.com",
        URI.parse("https://example.com/whatever")
      )

    assert Cookie.matched?(cookie, URI.parse("https://example.com/whatever"))
    assert Cookie.matched?(cookie, URI.parse("https://sub.example.com/whatever/something"))
    refute Cookie.matched?(cookie, URI.parse("https://sub.example.com/else"))
  end

  test "expired cookie" do
    cookie =
      Cookie.parse(
        "yummy_cookie=choco; Secure; Max-Age=-1",
        URI.parse("https://example.com/whatever")
      )

    refute Cookie.matched?(cookie, URI.parse("https://example.com/whatever"))
  end

  test "date parsing" do
    cookie =
      Cookie.parse(
        "yummy_cookie=choco; Secure; Expires=Wed, 21 Oct 2015 07:28:00 GMT",
        URI.parse("https://example.com/whatever")
      )

    refute Cookie.matched?(cookie, URI.parse("https://example.com/whatever"))
  end

  test "mailformed date" do
    assert nil ==
             Cookie.parse(
               "yummy_cookie=choco; Secure; Expires=Wed, 21 Oct 2015 07:28:00 XXX",
               URI.parse("https://example.com/whatever")
             )
  end

  test "cross domain cookie" do
    assert nil ==
             Cookie.parse(
               "yummy_cookie=choco; Secure; Domain=example2.com",
               URI.parse("https://example.com/whatever")
             )
  end
end
