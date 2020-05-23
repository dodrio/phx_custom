defmodule PhxCustom.HandleWeb do
  alias PhxCustom.Project
  alias PhxCustom.Generator
  alias PhxCustom.Reporter

  @app PhxCustom.MixProject.project()[:app]

  def patch(root) do
    assigns = Project.inspect(root)
    path = Keyword.get(assigns, :path)
    template_base = Path.expand("templates/web", :code.priv_dir(@app))

    [
      path.web_assets,
      path.web_statics,
      "#{path.web_lib}/controllers/*",
      "#{path.web_lib}/templates/*",
      "#{path.web_lib}/page_view.ex"
    ]
    |> Enum.map(&Path.join(root, &1))
    |> Generator.delete()

    Generator.copy_dir(
      Path.join(template_base, "assets"),
      Path.join(root, path.web_assets),
      assigns
    )

    Generator.copy_dir(
      Path.join(template_base, "lib/_web"),
      Path.join(root, path.web_lib),
      assigns
    )

    post_file = Path.join(template_base, "post-info.txt.eex")
    Reporter.report(post_file, assigns)
  end
end
