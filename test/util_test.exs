defmodule UtilTest do
  use Backend.DataCase, async: true
  doctest Util

  describe "mobile_user_agent?/1" do
    test "returns true for mobile user agents" do
      iphone =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"

      android =
        "Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.165 Mobile Safari/537.36"

      ipod = "Mozilla/5.0 (iPod touch; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15"

      assert Util.mobile_user_agent?(iphone)
      assert Util.mobile_user_agent?(android)
      assert Util.mobile_user_agent?(ipod)
    end

    test "returns false for desktop user agents and non-binary values" do
      mac =
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

      windows =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

      refute Util.mobile_user_agent?(mac)
      refute Util.mobile_user_agent?(windows)
      refute Util.mobile_user_agent?(nil)
      refute Util.mobile_user_agent?("")
      refute Util.mobile_user_agent?(123)
    end
  end
end
