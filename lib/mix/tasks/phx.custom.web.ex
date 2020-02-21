defmodule Mix.Tasks.Phx.Custom.Web do
  @shortdoc "Patch project with custom Web template"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.web <project>

  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.Web

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, _}) do
    root = Path.expand(project_root, File.cwd!())
    Web.patch(root)
  end
end
