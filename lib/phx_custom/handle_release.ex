defmodule PhxCustom.HandleRelease do
  alias PhxCustom.Project
  alias PhxCustom.Generator
  alias PhxCustom.Reporter

  @app PhxCustom.MixProject.project()[:app]

  def patch(root) do
    assigns = Project.inspect(root)
    template_base = Path.expand("templates/release", :code.priv_dir(@app))

    Generator.delete(
      [
        "config/prod.secret.exs"
      ]
      |> Enum.map(&Path.expand(&1, root))
    )

    Generator.copy_file(
      Path.join(template_base, "config/releases.exs"),
      Path.join(root, "config/releases.exs"),
      assigns
    )

    post_file = Path.join(template_base, "post-info.txt.eex")
    Reporter.report(post_file, assigns)
  end
end
