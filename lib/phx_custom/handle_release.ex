defmodule PhxCustom.HandleRelease do
  alias PhxCustom.Project
  alias PhxCustom.Generator
  alias PhxCustom.Reporter

  @app PhxCustom.MixProject.project()[:app]

  def patch(root) do
    assigns = Project.inspect(root)
    path = Keyword.get(assigns, :path)
    template_base = Path.expand("templates/release", :code.priv_dir(@app))

    [
      "config/prod.secret.exs"
    ]
    |> Enum.map(&Path.expand(&1, root))
    |> Generator.delete()

    Generator.copy_file(
      Path.join(template_base, "release.ex"),
      Path.join([root, path.ctx_lib, "release.ex"]),
      assigns
    )

    Generator.copy_file(
      Path.join(template_base, "config/releases.exs"),
      Path.join(root, "config/releases.exs"),
      assigns
    )

    post_file = Path.join(template_base, "post-info.md.eex")
    Reporter.report(post_file, assigns)
  end
end
