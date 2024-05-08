defmodule Backend.Reveals do
  @moduledoc "Info about reveals"

  alias Backend.UserManager.User

  def show?(reveal_slug, user) do
    revealed?(reveal_slug) or can_show_anyway?(user)
  end

  def revealed?(slug) do
    case reveal_time(slug) do
      %NaiveDateTime{} = reveal_time ->
        now = NaiveDateTime.utc_now()
        NaiveDateTime.compare(now, reveal_time) == :gt

      _ ->
        false
    end
  end

  def can_show_anyway?(%{battletag: bt}) when bt in ["RHat#1215", "D0nkey2470"], do: true
  def can_show_anyway?(u), do: User.can_access?(u, :reveals)

  def reveal_time(:boom) do
    ~N[2024-05-08T19:00:00]
  end

  def reveal_time(_), do: nil
end
