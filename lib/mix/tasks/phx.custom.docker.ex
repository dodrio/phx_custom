defmodule Mix.Tasks.Phx.Custom.Docker do
  @shortdoc "Patch project with Dockerfile"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.docker <project>

  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.Docker

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, _}) do
    root = Path.expand(project_root, File.cwd!())
    Docker.patch(root)
  end
end
