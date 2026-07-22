defmodule Backend.Api.RateLimiterTest do
  use ExUnit.Case, async: false

  alias Backend.Api.RateLimiter

  test "limits each key independently" do
    first_key = {:first, System.unique_integer([:positive])}
    second_key = {:second, System.unique_integer([:positive])}

    assert {:allow, 1, _reset_after_ms} = RateLimiter.hit(first_key, 2, 60_000)
    assert {:allow, 0, _reset_after_ms} = RateLimiter.hit(first_key, 2, 60_000)
    assert {:deny, retry_after_ms} = RateLimiter.hit(first_key, 2, 60_000)
    assert retry_after_ms > 0

    assert {:allow, 1, _reset_after_ms} = RateLimiter.hit(second_key, 2, 60_000)
  end
end
