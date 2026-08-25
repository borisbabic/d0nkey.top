defmodule BackendWeb.GiveawayLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Giveaways
  alias Components.Table
  alias Components.Table.Column
  alias Components.Helper
  import FunctionComponents.MiscComponents, only: [setup_step: 1]

  data(user, :any)
  data(giveaway, :any)
  data(entry, :any)
  data(entries, :list, [])
  data(creator?, :boolean, default: false)
  data(winners, :list, [])

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(%{creator?: true} = assigns) do
    ~F"""
    <div>
      <.page_header title={@giveaway.name} />
      <.table id={"creator_table"}>
        <.tbody>
          <.trb>
            <.td>Deadline</.td>
            <.td>
              <div class="tw-grid tw-grid-cols-1">
                <span>{NaiveDateTime.to_iso8601(@giveaway.deadline)}</span>
                <span>{render_datetime(@giveaway.deadline)}</span>
              </div>
            </.td>
          </.trb>
          <.trb>
            <.td>Num Winners:</.td>
            <.td>{Enum.count(@entries, & &1.winner)}/{@giveaway.number_of_winners}</.td>
          </.trb>
          <.trb>
            <.td>Num Entries:</.td>
            <.td>{Enum.count(@entries)}</.td>
          </.trb>
          <.trb>
            <.td>Codes Count:</.td>
            <.td>{Enum.count(@giveaway.codes || [])}</.td>
          </.trb>
        </.tbody>
      </.table>

      <div class="tw-my-6 tw-p-6 tw-border tw-border-slate-800 tw-rounded-2xl tw-bg-slate-800/20 tw-space-y-4">
        <h3 class="tw-text-base tw-font-bold text-white">Codes / Messages for Winners</h3>
        <p class="tw-text-sm tw-text-slate-400">
          Enter one code or message per line. Each winner will receive one code in order (Winner 1 gets the 1st code, Winner 2 gets the 2nd code, etc.).
        </p>
        <.form for={%{}} as={:codes_form} id="giveaway_codes_form" phx-submit="save_codes">
          <div class="tw-mb-3">
            <textarea
              name="codes"
              id="giveaway_codes_input"
              rows="5"
              class="textarea tw-font-mono tw-w-full has-text-black"
              placeholder={"CODE-1\nCODE-2"}
            >{Enum.join(@giveaway.codes || [], "\n")}</textarea>
          </div>
          <button type="submit" id="save_codes_btn" class="button is-info is-small">Save Codes</button>
        </.form>
      </div>

      <div class="tw-my-4">
        <button id="pick_winners_btn" class="button is-primary" :on-click="pick_winners">Pick Winners</button>
      </div>

      <Table id="entries_table" data={entry <- @entries} >
        <Column label="Battletag"><Helper.player_name name={entry.user.battletag} country={true} /></Column>
        <Column label="Winner">{entry.winner}</Column>
        <Column label="Code / Message">{entry.code || "-"}</Column>
      </Table>
    </div>
    """
  end

  def render(%{creator?: false} = assigns) do
    ~F"""
    <div>
      <.page_header title={@giveaway.name} />
      <div class="tw-grid tw-grid-cols-1 tw-gap-4">
        <div class="tw-p-6 tw-border tw-border-slate-800 tw-rounded-2xl tw-bg-slate-800/20 tw-space-y-4" :if={@entry && @entry.winner}>
          <div class="tw-flex tw-items-center tw-gap-2 has-text-success">
            <span class="tw-text-xl">🎊</span>
            <h3 class="tw-text-lg tw-font-bold text-white">Congrats! You won!</h3>
          </div>
          <div class="tw-text-sm tw-text-slate-400 tw-leading-relaxed">
            <div :if={@entry.code && @entry.code != ""}> 
              Your code is: <pre id="winner_code" class="tw-mt-2 tw-p-3 tw-bg-slate-900 tw-rounded-lg tw-text-white tw-font-mono tw-text-base tw-select-all">{@entry.code}</pre>
            </div>

            <span :if={!@entry.code || @entry.code == ""}>
              The giveaway creator will add you on battlenet and send you the code
            </span>
          </div>
        </div>
        <div class="tw-p-6 tw-border tw-border-slate-800 tw-rounded-2xl tw-bg-slate-800/20 tw-space-y-4" :if={(!@entry or !@entry.winner) and winners_picked?(@giveaway, @winners)}>
          <div class="tw-flex tw-items-center tw-gap-2 has-text-success">
            <span class="tw-text-xl">🎉</span>
            <h3 class="tw-text-lg tw-font-bold text-white">The giveaway is over</h3>
          </div>
          <p class="tw-text-sm tw-text-slate-400 tw-leading-relaxed">
            Congrats to the winner(s): <span>{Enum.join(@winners, ", ")}</span>
          </p>
        </div>
        <div class="tw-p-6 tw-border tw-border-slate-800 tw-rounded-2xl tw-bg-slate-800/20 tw-space-y-4" :if={@giveaway.description || @giveaway.deadline }>
          <div class="tw-flex tw-items-center tw-gap-2 has-text-success">
            <span class="tw-text-xl">🎁</span>
            <h3 class="tw-text-lg tw-font-bold text-white">It's giveaway time!</h3>
          </div>
          <p class="tw-text-sm tw-text-slate-400 tw-leading-relaxed">
            <div :if={@giveaway.description}>
              {@giveaway.description}
            </div>

            <div :if={@giveaway.deadline} class="tw-text-sm tw-text-slate-100">
              Deadline: <Helper.datetime class="tw-text-sm tw-text-slate-400" datetime={@giveaway.deadline} />
            </div>
          </p>
        </div>
        <.setup_step title="Enter the giveaway" is_done={@entry}>
          <div :if={@entry}>
            You're already entered!
          </div>
          <div :if={!@user && !@entry}>
            You need to <a target="_blank" href="/auth/bnet">login</a> before you can enter 
          </div>
          <div :if={@user && !@entry && !Util.before_now?(@giveaway.deadline)}>
            <button class="button" :on-click={"enter"}>Click here to enter</button>
          </div>
          <div :if={!@entry && Util.before_now?(@giveaway.deadline)}>
            The deadline has passed 🥲
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
    creator? = giveaway.creator_id == Map.get(user || %{}, :id)

    {entry, entries} =
      if creator? do
        entries = Giveaways.get_entries(giveaway, user) |> sort_entries()
        {nil, entries}
      else
        {Giveaways.get_entry(giveaway, user), []}
      end

    winners = Giveaways.winner_names(giveaway)

    {
      :noreply,
      socket
      |> assign(entry: entry, giveaway: giveaway, creator?: creator?, entries: entries, winners: winners)
    }
  end

  def handle_event("enter", _, %{assigns: %{user: user, giveaway: giveaway}} = socket) do
    {:ok, entry} = Giveaways.enter(giveaway, user)

    {:noreply, socket |> assign(entry: entry)}
  end

  def handle_event("save_codes", params, %{assigns: %{giveaway: giveaway, creator?: true, user: user}} = socket) do
    codes_raw = Map.get(params, "codes") || get_in(params, ["codes_form", "codes"]) || ""

    case Giveaways.save_codes(giveaway, codes_raw) do
      {:ok, updated_giveaway} ->
        entries = Giveaways.get_entries(updated_giveaway, user) |> sort_entries()
        giveaway = Giveaways.preload_giveaway(updated_giveaway)
        {:noreply, socket |> assign(giveaway: giveaway, entries: entries)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("pick_winners", _, %{assigns: %{user: user, giveaway: giveaway}} = socket) do
    giveaway = Giveaways.get_giveaway!(giveaway.id)
    {:ok, new_entries} = Giveaways.pick_winners(giveaway, user)
    winners = Giveaways.winner_names(giveaway)

    {:noreply, socket |> assign(entries: sort_entries(new_entries), winners: winners, giveaway: giveaway)}
  end

  defp sort_entries(entries) do
    entries
    |> Enum.sort_by(fn %{user: %{battletag: btag}} -> btag end, :asc)
    |> Enum.sort_by(fn %{winner: winner} -> winner end, :desc)
  end

  defp winners_picked?(%{number_of_winners: num}, winners), do: Enum.count(winners) == num
end
