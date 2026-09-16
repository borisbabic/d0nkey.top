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
  @sage %{
    display: "Sage Georigiu",
    link: nil
  }
  @puffin %{
    display: "Stephen “Puffin” Chang ",
    link: nil
  }
  @steve_rubin %{
    display: "Steve Rubin",
    link: nil
  }

  @cora %{
    display: "Cora Georgiou",
    link: nil
  }

  @bionic_door %{
    display: "Lucas \“Bionic Door\” Waitkuweit",
    link: nil
  }
  @gallon %{
    display: "Edward “Gallon” Goodwin",
    link: nil
  }

  @frodan %{
    display: "Frodan",
    link: "https://www.twitch.tv/frodan"
  }
  @mcbanterface %{
    display: "mcbanterFace",
    link: "https://www.twitch.tv/mcbanterface"
  }
  @nohands %{
    display: "NoHandsGamer",
    link: "https://www.twitch.tv/nohandsgamer"
  }

  @redbeard %{
    display: "Redbeard",
    link: "https://www.twitch.tv/redbeard"
  }

  @edelweiss %{
    display: "Edelweiss",
    link: "https://bsky.app/profile/edelweissccg.bsky.social"
  }
  @dekkster %{
    display: "Dekkster",
    link: "https://www.youtube.com/@Dekkster"
  }

  @reqvam %{
    display: "reqvam",
    link: "https://www.twitch.tv/reqvam"
  }

  @redbeard %{
    display: "",
    link: "https://www.twitch.tv/"
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
  @raven %{
    display: "Raven",
    link: "https://www.twitch.tv/RavenHS"
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
        start_time: ~N[2026-06-23 21:00:00],
        host: nil,
        classes: [],
        devs: [@edward_goodwin],
        guests: [@regis],
        display: "Final Reveal Stream!"
      },
      %__MODULE__{
        slug: "black_empire_1",
        start_time: ~N[2026-09-22 21:00:00],
        host: @raven,
        classes: ["MAGE"],
        devs: [@bionic_door, @gallon],
        guests: [@frodan, @mcbanterface]
      },
      %__MODULE__{
        slug: "black_empire_2",
        start_time: ~N[2026-09-23 21:00:00],
        host: @raven,
        classes: ["PALADIN"],
        devs: [@cora, @ben_paulsen],
        guests: [@edelweiss, @dekkster]
      },
      %__MODULE__{
        slug: "black_empire_3",
        start_time: ~N[2026-09-24 21:00:00],
        host: @raven,
        classes: ["DRUID"],
        devs: [@sage, @decktech],
        guests: [@nohands, @redbeard]
      },
      %__MODULE__{
        slug: "black_empire_4",
        start_time: ~N[2026-09-25 21:00:00],
        host: @raven,
        classes: ["HUNTER"],
        devs: [@puffin, @steve_rubin],
        guests: [@kibler, @reqvam]
      }
    ]
  end

  def get(slug) do
    Enum.find(all(), &(&1.slug == slug))
  end
end
