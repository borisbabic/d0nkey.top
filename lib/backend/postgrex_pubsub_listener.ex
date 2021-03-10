defmodule Backend.PostgrexPubsubListener do
  use PostgrexPubsub.Listener, repo: Backend.Repo

  def handle_mutation_event(%{"id" => row_id, "table" => table, "type" => type}) do
    BackendWeb.Endpoint.broadcast_from(self(), "entity_#{table}_#{row_id}", type, %{
      id: row_id,
      table: table,
      type: type
    })
  end
end
