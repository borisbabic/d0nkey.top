defmodule Backend.PostgrexPubsubListener do
  @moduledoc false
  use PostgrexPubsub.Listener, repo: Backend.Repo

  def handle_mutation_event(%{"id" => row_id, "table" => table, "type" => type}) do
    payload = %{id: row_id, table: table, type: type}
    BackendWeb.Endpoint.broadcast_from(self(), "entity_#{table}_#{row_id}", type, payload)

    if type == "INSERT" do
      BackendWeb.Endpoint.broadcast_from(self(), "entity_#{table}", "INSERT", payload)
    end
  end
end
