defmodule PhxCustom.Yarn do
  alias PhxCustom.Project

  def run(root, rest_args) do
    assigns = Project.inspect(root)
    web_root = Keyword.get(assigns, :web_root)

    yarn_cwd = Path.join([root, web_root, "assets"])
    yarn_cwd_relative_to_root = Path.join([web_root, "assets"])

    IO.puts("> cd #{yarn_cwd_relative_to_root}")

    System.cmd("yarn", ["--cwd", yarn_cwd | rest_args], into: IO.stream(:stdio, :line))
  end
end
