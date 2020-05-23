defmodule PhxCustom.HandleWeb do
  alias PhxCustom.Project
  alias PhxCustom.Generator
  alias PhxCustom.Reporter

  @app PhxCustom.MixProject.project()[:app]

  defp get_template_base() do
    Path.expand("templates/web", :code.priv_dir(@app))
  end

  def patch(root) do
    assigns = Project.inspect(root)
    path = Keyword.get(assigns, :path)
    template_base = get_template_base()

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

    post_file = Path.join(template_base, "post-info.md.eex")
    Reporter.report(post_file, assigns)
  end

  def patch_existing(root) do
    assigns = Project.inspect(root)
    path = Keyword.get(assigns, :path)
    template_base = get_template_base()

    [
      "babel.config.js",
      "package.json",
      "webpack.config.js"
    ]
    |> Enum.map(fn file ->
      src = Path.join([template_base, "assets", file])
      dest = Path.join([root, path.web_assets, file])

      {src, dest}
    end)
    |> Enum.each(fn {src, dest} ->
      Generator.copy_file(src, dest, assigns)
    end)
  end
end
