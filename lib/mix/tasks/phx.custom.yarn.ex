defmodule Mix.Tasks.Phx.Custom.Yarn do
  @shortdoc "Run yarn for assets without changing directory"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.yarn <project> [args supported by yarn]

  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.Yarn

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, rest_args}) do
    root = Path.expand(project_root, File.cwd!())
    Yarn.run(root, rest_args)
  end
end
