defmodule Mix.Tasks.Phx.Custom.Web do
  @shortdoc "Patch project with custom assets and templates"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.web <project> [options]

  ## options

  + `--update` - update webpack config for patched projects.
  """

  use Mix.Task

  alias PhxCustom.CLI
  alias PhxCustom.HandleWeb

  @impl Mix.Task
  def run(args) do
    CLI.parse(args)
    |> process
  end

  def process({project_root, rest_args}) do
    parsed = OptionParser.parse(rest_args, strict: [update: :boolean])

    case parsed do
      {[update: true], _, _} ->
        HandleWeb.patch_existing(project_root)

      _ ->
        HandleWeb.patch(project_root)
    end
  end
end
