defmodule PhxCustom.HandleDocker do
  alias PhxCustom.Project
  alias PhxCustom.Generator
  alias PhxCustom.Reporter

  @app PhxCustom.MixProject.project()[:app]

  def patch(root) do
    assigns = Project.inspect(root)
    template_base = Path.expand("templates/docker", :code.priv_dir(@app))
    type = Keyword.get(assigns, :type)

    Generator.copy_file(
      Path.join(template_base, "#{type}.dockerfile"),
      Path.join(root, "Dockerfile"),
      assigns
    )

    Generator.copy_file(
      Path.join(template_base, "dockerignore"),
      Path.join(root, ".dockerignore"),
      assigns
    )

    post_file = Path.join(template_base, "post-info.txt.eex")
    Reporter.report(post_file, assigns)
  end
end
