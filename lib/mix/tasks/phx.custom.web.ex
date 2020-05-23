defmodule Mix.Tasks.Phx.Custom.Web do
  @shortdoc "Patch project with custom Web templates"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.web <project>

  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.HandleWeb

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, _}) do
    HandleWeb.patch(project_root)
  end
end
