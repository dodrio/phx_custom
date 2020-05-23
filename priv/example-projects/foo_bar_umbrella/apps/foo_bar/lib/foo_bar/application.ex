defmodule FooBar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FooBar.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: FooBar.PubSub}
      # Start a worker by calling: FooBar.Worker.start_link(arg)
      # {FooBar.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: FooBar.Supervisor)
  end
end
