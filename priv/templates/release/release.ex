defmodule <%= @module_ctx %>.Release do
  @app :<%= @app_ctx %>
  @extra_apps []

  @moduledoc """
  Run the functions in this module by calling `eval` command provided by
  release.

  Run a function manually:

       _build/prod/rel/<%= @app_ctx %>/bin/<%= @app_ctx %> eval "<%= @module_ctx %>.Release.migrate()"


  Run a function automatically when starting a release:

  ```sh
  # mix release.init && $EDITOR rel/env.sh.eex
  case $RELEASE_COMMAND in
      start*)
          "$RELEASE_ROOT/bin/$RELEASE_NAME" eval "<%= @module_ctx %>.Release.migrate()"
          ;;
      *)
          ;;
  esac
  ```

  Read more details at https://hexdocs.pm/phoenix/releases.html.
  """

  def migrate do
    load_apps()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_apps()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    load_apps()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &seed_for/1)
    end
  end

  defp load_apps() do
    [@app | @extra_apps]
    |> Enum.each(&Application.load/1)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp seed_for(repo) do
    seed_file = priv_path_for(repo, "seeds.exs")

    if File.exists?(seed_file) do
      Code.eval_file(seed_file)
    end
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config(), :otp_app)
    priv_dir = "#{:code.priv_dir(app)}"

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    Path.join([priv_dir, repo_underscore, filename])
  end
end
