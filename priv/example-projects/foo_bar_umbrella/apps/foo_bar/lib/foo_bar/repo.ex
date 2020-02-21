defmodule FooBar.Repo do
  use Ecto.Repo,
    otp_app: :foo_bar,
    adapter: Ecto.Adapters.Postgres
end
