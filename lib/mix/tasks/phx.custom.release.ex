defmodule Mix.Tasks.Phx.Custom.Release do
  @shortdoc "Patch project for using `mix release`"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.release <project>

  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.HandleRelease

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, _}) do
    HandleRelease.patch(project_root)
  end
end
