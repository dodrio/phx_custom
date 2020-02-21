defmodule Mix.Tasks.Phx.Custom.Config do
  @shortdoc "Patch project with custom config template"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.config <project>

  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.Config

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, _}) do
    root = Path.expand(project_root, File.cwd!())
    Config.patch(root)
  end
end
