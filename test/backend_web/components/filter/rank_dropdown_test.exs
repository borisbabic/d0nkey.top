defmodule Components.Filter.RankDropdownTest do
  use Backend.DataCase
  alias Components.Filter.RankDropdown
  import Hearthstone.DeckTrackerFixtures

  defp option_slugs(context, user) do
    RankDropdown.options(context, false, user)
    |> Enum.map(&elem(&1, 0))
  end

  describe "options/3" do
    test "hides premium_only ranks from anonymous and regular users" do
      rank_fixture(%{slug: "legend_free", premium_only: false})
      rank_fixture(%{slug: "top_500_premium", premium_only: true})

      anonymous_slugs = option_slugs(:public, nil)
      assert "legend_free" in anonymous_slugs
      refute "top_500_premium" in anonymous_slugs

      refute "top_500_premium" in option_slugs(:public, %{})
    end

    test "shows premium_only ranks to premium users" do
      rank_fixture(%{slug: "legend_free", premium_only: false})
      rank_fixture(%{slug: "top_500_premium", premium_only: true})

      premium_slugs = option_slugs(:public, %{premium: true})
      assert "top_500_premium" in premium_slugs
      assert "legend_free" in premium_slugs
    end

    test "also hides premium_only ranks in the personal context for regular users" do
      rank_fixture(%{slug: "top_500_premium", premium_only: true})

      refute "top_500_premium" in option_slugs(:personal, %{})
      assert "top_500_premium" in option_slugs(:personal, %{premium: true})
    end
  end
end
