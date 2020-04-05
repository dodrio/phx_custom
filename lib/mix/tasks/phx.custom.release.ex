defmodule Mix.Tasks.Phx.Custom.Release do
  @shortdoc "Patch project for using `mix release`"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.release <project>

  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.Release

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, _}) do
    root = Path.expand(project_root, File.cwd!())
    Release.patch(root)
  end
end
