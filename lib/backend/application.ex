defmodule Backend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children =
      [
        # Start the Ecto repository
        Backend.Repo,
        # Start the endpoint when the application starts
        BackendWeb.Endpoint,
        # Starts a worker by calling: Backend.Worker.start_link(arg)
        # {Backend.Worker, arg},
        %{
          id: Backend.Infrastructure.ApiCache,
          start: {Backend.Infrastructure.ApiCache, :start_link, [[]]}
        },
        %{
          id: Backend.Infrastructure.HSReplayLatestCache,
          start: {Backend.Infrastructure.HSReplayLatestCache, :start_link, [[]]}
        },
        %{
          id: Backend.Infrastructure.PlayerStatsCache,
          start: {Backend.Infrastructure.PlayerStatsCache, :start_link, [[]]}
        },
        {Task, &warmup_cache/0},
        QuantumScheduler
      ]
      |> check_bot()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Backend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def check_bot(prev) do
    if Application.fetch_env!(:backend, :enable_bot) do
      prev ++ [Bot.Consumer]
    else
      prev
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def warmup_cache() do
    if Application.fetch_env!(:backend, :warmup_cache) do
      try do
        Backend.MastersTour.warmup_stats_cache()
      rescue
        _ -> nil
      catch
        _ -> nil
      end
    end
  end
end
