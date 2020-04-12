defmodule Backend.Infrastructure.DiscordCommunicator do
  @moduledoc false
  @behaviour Backend.Discord.Communicator
  def broadcast_file(path, name, url) do
    form = {:multipart, [{:file, path, {"form-data", [{"filename", name}]}, []}]}
    {success, _} = HTTPoison.post(url, form)
    success
  end
end
