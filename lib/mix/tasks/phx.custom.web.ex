defmodule Mix.Tasks.Phx.Custom.Web do
  @shortdoc "Patch project with custom assets and templates"

  @moduledoc """
  #{@shortdoc}.

      mix phx.custom.web <project> [options]

  This task provides following features:

  - enhanced assets pipeline:
    - built-in [tailwindcss](https://tailwindcss.com/) support
    - source map support for JavaScript and CSS
  - separation for app and admin:
    - standalone frontend resources for app and admin
    - standalone namespaces for app and admin views

  > What is the meaning of app or admin?
  > Generally, a web application consists of two sub applications, one for users
  > , one for administrators. In the context of `phx_custom`, the code for
  > users is called `app`, the code for administrators is called `admin`.

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
