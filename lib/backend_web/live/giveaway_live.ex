defmodule BackendWeb.GiveawayLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Giveaways
  alias Backend.PlayerInfo
  alias Components.Table
  alias Components.Table.Column
  alias Components.Helper
  import FunctionComponents.MiscComponents, only: [setup_step: 1]

  data(user, :any)
  data(giveaway, :any)
  data(entry, :any)
  data(entries, :list, [])
  data(creator?, :boolean, default: false)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(%{creator?: true} = assigns) do
    ~F"""
    <div>
      <div class="tw-grid tw-cols-2">
        <span>Deadline:</span><span>{NaiveDateTime.to_iso8601(@giveaway.deadline)}|{render_datetime(@giveaway.deadline)}</span>
        <span>Num Winners:</span><span>{Enum.count(@entries, & &1.winner)/@giveaway.number_of_winners}</span>
        <button class="button" :on-click="pick_winners">Pick Winners</button>
      </div>
      <Table id="entries_table" data={entry <- @entries} >
        <Column label="Battletag">{entry.user.battletag}</Column>
        <Column label="Winner">{entry.winner}</Column>
      </Table>
    </div>
    """
  end

  def render(%{creator?: false} = assigns) do
    ~F"""
    <div>
      <.page_header title={@giveaway.name} />
      <div class="tw-p-6 tw-border tw-border-slate-800 tw-rounded-2xl tw-bg-slate-800/20 tw-space-y-4" :if={@giveaway.description}>
        <div class="tw-flex tw-items-center tw-gap-2 has-text-success">
          <span class="tw-text-xl">🎁</span>
          <h3 class="tw-text-lg tw-font-bold text-white">It's giveaway time!</h3>
        </div>
        <p class="tw-text-sm tw-text-slate-400 tw-leading-relaxed">
          {@giveaway.description}

          <div :if={@giveaway.deadline} class="tw-text-sm tw-text-slate-100">
            Deadline: <Helper.datetime class="tw-text-sm tw-text-slate-400" datetime={@giveaway.deadline} />

          </div>
        </p>
      </div>
      <div class="tw-grid tw-grid-cols-1 tw-gap-4">
        <.setup_step title="Enter the giveaway" is_done={@entry}>
          <div :if={@entry}>
            You're already entered!
          </div>
          <div :if={!@user && !@entry}>
            You need to <a target="_blank" href="/auth/bnet">login</a> before you can enter 
          </div>
          <div :if={@user && !@entry}>
            <button class="button" :on-click={"enter"}>Click here to enter</button>
          </div>
        </.setup_step>

        <.setup_step title="Country Flag" is_done={@user && @user.country_code}>
          Set your country flag in settings to represent your country on the site and get an extra ticket!
          <br>
          <a target="_blank" href="/profile/settings">Click here to go to settings</a>.
        </.setup_step>
      </div>
    </div>
    """
  end

  def handle_params(%{"giveaway_id" => id}, _session, %{assigns: %{user: user}} = socket) do
    giveaway = Giveaways.get_giveaway!(id)
    creator? = giveaway.creator_id == Map.get(user || %{}, id)

    {entry, entries} =
      if creator? do
        {nil, Giveaways.get_entries(giveaway, user) |> sort_entries()}
      else
        {Giveaways.get_entry(giveaway, user), []}
      end

    {
      :noreply,
      socket
      |> assign(entry: entry, giveaway: giveaway, creator?: creator?, entries: entries)
    }
  end

  def handle_event("enter", _, %{assigns: %{user: user, giveaway: giveaway}} = socket) do
    {:ok, entry} = Giveaways.enter(giveaway, user)

    {:noreply, socket |> assign(entry: entry)}
  end

  def handle_event("pick_winners", _, %{assigns: %{user: user, giveaway: giveaway}} = socket) do
    {:ok, new_entries} = Giveaways.pick_winners(giveaway, user)

    {:noreply, socket |> assign(entries: new_entries)}
  end

  defp sort_entries(entries) do
    entries
    |> Enum.sort_by(fn %{user: %{battletag: btag}} -> btag end, :asc)
    |> Enum.sort_by(fn %{winner: winner} -> winner end, :desc)
  end
end
