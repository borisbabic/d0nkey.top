defmodule BackendWeb.IncendiumController do
  use Incendium.Controller,
    routes_module: BackendWeb.Router.Helpers,
    otp_app: :backend
end
