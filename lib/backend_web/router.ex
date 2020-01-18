defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BackendWeb do
    pipe_through :browser

    get "/leaderboard", LeaderboardController, :index
    get "/", PageController, :index
    get "/invited/:tour_stop", MastersTourController, :invited_players
    get "/qualifiers", MastersTourController, :qualifiers
    get "/battlefy/tournament/:tournament_id", BattlefyController, :tournament
  end

  # Other scopes may use custom stacks.
  # scope "/api", BackendWeb do
  #   pipe_through :api
  # end
end
