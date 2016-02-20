defmodule Constable do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    unless Mix.env == "production" do
      Envy.auto_load
    end

    setup_dependencies

    children = [
      # Start the endpoint when the application starts
      worker(Constable.Endpoint, []),
      worker(Constable.Repo, []),
      Bamboo.TaskSupervisorStrategy.child_spec

      # Here you could define other workers and supervisors as children
      # worker(Constable.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Constable.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp setup_dependencies do
    {:ok, _} = Pact.start
    Pact.put(:request_with_access_token, OAuth2.AccessToken)
    Pact.put(:token_retriever, OAuth2.Strategy.AuthCode)
    Pact.put(:daily_digest, Constable.DailyDigest)
    Pact.put(:google_strategy, GoogleStrategy)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Constable.Endpoint.config_change(changed, removed)
    :ok
  end
end
