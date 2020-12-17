defmodule BackendWeb.Presence do
  use Phoenix.Presence,
    otp_app: :backend,
    pubsub_server: Backend.PubSub
end
