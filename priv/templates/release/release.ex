defmodule <%= @module_ctx %>.Release do
  @app :<%= @app_ctx %>
  @extra_apps []

  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.

  Run the functions in this module by calling `eval` command provided by
  release.

  ## Run a function manually

  ```sh
  $RELEASE_ROOT/bin/$RELEASE_NAME eval "<%= @module_ctx %>.Release.migrate()"

  $RELEASE_ROOT/bin/$RELEASE_NAME eval "<%= @module_ctx %>.Release.rollback()"

  $RELEASE_ROOT/bin/$RELEASE_NAME eval "<%= @module_ctx %>.Release.migrate_manual()"

  $RELEASE_ROOT/bin/$RELEASE_NAME eval "<%= @module_ctx %>.Release.rollback_manual()"

  $RELEASE_ROOT/bin/$RELEASE_NAME eval "<%= @module_ctx %>.Release.seed()"
  ```

  ## Run a function automatically

  For example, when starting a release:

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
      path = path_for_migrations(repo)
      run_migrations(repo, path)
    end
  end

  def rollback(repo, version) do
    load_apps()
    path = path_for_migrations(repo)
    rollback_migrations(repo, path, version)
  end

  def migrate_manual do
    load_apps()

    for repo <- repos() do
      path = path_for_manual_migrations(repo)
      run_migrations(repo, path)
    end
  end

  def rollback_manual(repo, version) do
    load_apps()
    path = path_for_manual_migrations(repo)
    rollback_migrations(repo, path, version)
  end

  def seed() do
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

  defp path_for_migrations(repo) do
    Ecto.Migrator.migrations_path(repo)
  end

  defp path_for_manual_migrations(repo) do
    # requires Ecto v3.4+:
    Ecto.Migrator.migrations_path(repo, "manual_migrations")
  end

  defp run_migrations(repo, path) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, path, :up, all: true))
  end

  defp rollback_migrations(repo, path, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, path, :down, to: version))
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
