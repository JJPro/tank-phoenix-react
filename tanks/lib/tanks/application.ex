defmodule Tanks.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Tanks.Repo, []),
      # Start the endpoint when the application starts
      supervisor(TanksWeb.Endpoint, []),
      # Start your own worker by calling: Tanks.Worker.start_link(arg1, arg2, arg3)
      # worker(Tanks.Worker, [arg1, arg2, arg3]),
      worker(Tanks.RoomStore, []),
      worker(Tanks.ChatStore, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tanks.Supervisor]

    # for users-online indicator
    if :ets.info(:users_online) == :undefined do
      :ets.new(:users_online, [:named_table, :public])
    end
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TanksWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
