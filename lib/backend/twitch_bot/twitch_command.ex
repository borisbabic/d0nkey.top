defmodule Backend.TwitchBot.TwitchCommand do
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.User

  schema "twitch_commands" do
    belongs_to :user, User
    field :enabled, :boolean, default: true
    field :message, :string
    field :message_regex, :boolean, default: false
    field :message_regex_flags, :string, default: "iu"
    field :name, :string
    field :random_chance, :float
    field :response, :string
    field :sender, :string
    field :sender_regex, :boolean, default: false
    field :sender_regex_flags, :string, default: "iu"
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(twitch_command, attrs) do
    twitch_command
    |> cast(attrs, [:type, :name, :enabled, :message, :response, :message_regex, :message_regex_flags, :sender, :sender_regex, :sender_regex_flags, :random_chance, :user_id])
    |> validate_required([:type, :enabled, :response])
    |> foreign_key_constraint(:user_id)
  end

end
