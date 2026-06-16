defmodule Backend.Feed.RevealStream do
  @moduledoc false
  use TypedStruct
  @derive JSON.Encoder

  @type participant() :: %{
          display: String.t(),
          link: String.t() | nil
        }

  typedstruct enforce: true do
    field :slug, String.t()
    field :start_time, NaiveDateTime.t()
    field :guests, [Participant.t()]
    field :devs, [Participant.t()]
    field :host, Participant.t() | nil
    field :classes, [String.t()]
    field :display, :string, default: nil
    field :twitch_channel, :string, default: "playhearthstone"
    field :drops, :boolean, default: true
  end

  @ben_paulsen %{
    display: "Ben Paulsen",
    link: nil
  }
  @alex_smith %{
    display: "Alex Smith",
    link: nil
  }
  @decktech %{
    display: "Nicholas \"Decktech\" Weiss",
    link: nil
  }
  @nate_kaplan %{
    display: "Nate Kaplan",
    link: nil
  }
  @edward_goodwin %{
    display: "Edward Goodwin",
    link: nil
  }
  @rarran %{
    display: "Rarran",
    link: "https:/www.twitch.tv/rarran"
  }
  @firebat %{
    display: "Firebat",
    link: "https://www.twitch.tv/firebat"
  }
  @regis %{
    display: "Regis Killbin",
    link: "https://www.youtube.com/@RegisKillbin"
  }
  @kibler %{
    display: "Brian Kibler",
    link: "https://www.youtube.com/@bmkibler"
  }
  @talso %{
    display: "Talso",
    link: "https://www.twitch.tv/talso"
  }
  @sunglitters %{
    display: "Sunglitters",
    link: "https://www.twitch.tv/sunglitters"
  }
  @trump %{
    display: "TrumpSC",
    link: "https://www.youtube.com/@TrumpSC"
  }
  @zeddy %{
    display: "Zeddy",
    link: "https://www.youtube.com/@ZeddyHearthstone"
  }
  @blisterguy %{
    display: "Blisterguy",
    link: "https://open.spotify.com/show/0Q8RRCEDX4cbDaFdmLO1Io?si=97114f24f8df4094"
  }

  def all do
    [
      %__MODULE__{
        slug: "violet_hold_1",
        start_time: ~N[2026-06-09 21:00:00],
        host: @rarran,
        classes: ["SHAMAN", "ROGUE", "DEMONHUNTER"],
        devs: [@ben_paulsen],
        guests: [
          @firebat,
          @regis
        ]
      },
      %__MODULE__{
        slug: "violet_hold_2",
        start_time: ~N[2026-06-11 21:00:00],
        host: @rarran,
        classes: ["PRIEST", "WARRIOR", "WARLOCK"],
        devs: [@alex_smith],
        guests: [
          @talso,
          @kibler
        ]
      },
      %__MODULE__{
        slug: "violet_hold_3",
        start_time: ~N[2026-06-16 21:00:00],
        host: @rarran,
        classes: ["MAGE", "DRUID"],
        devs: [@decktech],
        guests: [
          @sunglitters,
          @trump
        ]
      },
      %__MODULE__{
        slug: "violet_hold_4",
        start_time: ~N[2026-06-18 21:00:00],
        host: @rarran,
        classes: ["HUNTER", "PALADIN", "DEATHKNIGHT"],
        devs: [@nate_kaplan],
        guests: [
          @zeddy,
          @blisterguy
        ]
      },
      %__MODULE__{
        slug: "violet_hold_final",
        start_time: ~N[2026-06-18 21:00:00],
        host: nil,
        classes: [],
        devs: [@edward_goodwin],
        guests: [@regis],
        display: "Final Reveal Stream!"
      }
    ]
  end

  def get(slug) do
    Enum.find(all(), &(&1.slug == slug))
  end
end
