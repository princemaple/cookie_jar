defmodule CookieJarTest do
  use ExUnit.Case
  doctest CookieJar

  setup do
    {:ok, jar} = CookieJar.new()
    [jar: jar]
  end

  test "simple cookie", context do
    jar = context[:jar]
    CookieJar.pour(jar, ["yummy_cookie=choco"], "https://example.com")

    assert "yummy_cookie=choco" ==
             CookieJar.label(jar, "https://example.com")

    assert "" ==
             CookieJar.label(jar, "https://sub.example.com")
  end

  test "domain cookie", context do
    jar = context[:jar]

    CookieJar.pour(
      jar,
      [
        "yummy_cookie=choco; Domain=example.com",
        "bad_cookie=coco"
      ],
      "https://example.com"
    )

    assert "bad_cookie=coco; yummy_cookie=choco" ==
             CookieJar.label(jar, "https://example.com")

    assert "yummy_cookie=choco" ==
             CookieJar.label(jar, "https://sub.example.com")
  end

  test "sub domain cookie", context do
    jar = context[:jar]
    CookieJar.pour(jar, ["yummy_cookie=choco; Domain=example.com"], "https://example.com")
    CookieJar.pour(jar, ["bad_cookie=coco"], "https://sub.example.com")

    assert "bad_cookie=coco; yummy_cookie=choco" ==
             CookieJar.label(jar, "https://sub.example.com")
  end
end
