defmodule PhxCustom.Web do
  alias PhxCustom.Project
  alias PhxCustom.Generator
  alias PhxCustom.Reporter

  @app PhxCustom.MixProject.project()[:app]

  def patch(root) do
    assigns = Project.inspect(root)

    project_name = Keyword.get(assigns, :project_name)
    web_root = Keyword.get(assigns, :web_root)
    template_base = Path.expand("templates/web", :code.priv_dir(@app))

    Generator.delete(
      [
        "assets",
        "priv/static",
        "lib/#{project_name}_web/controllers/*",
        "lib/#{project_name}_web/templates/*",
        "lib/#{project_name}_web/views/page_view.ex"
      ]
      |> Enum.map(&Path.join([root, web_root, &1]))
    )

    Generator.copy_dir(
      Path.join(template_base, "assets"),
      Path.join([root, web_root, "assets"]),
      assigns
    )

    Generator.copy_dir(
      Path.join(template_base, "lib/_web"),
      Path.join([root, web_root, "lib/#{project_name}_web"]),
      assigns
    )

    post_file = Path.join(template_base, "post-info.txt.eex")
    Reporter.report(post_file, assigns)
  end
end
