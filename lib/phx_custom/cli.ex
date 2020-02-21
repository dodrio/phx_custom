defmodule PhxCustom.CLI do
  alias PhxCustom.File, as: MyFile

  def parse(args) do
    args
    |> args_to_internal_representation()
    |> validate()
  end

  defp args_to_internal_representation([project_root | rest_args]) do
    {project_root, rest_args}
  end

  defp args_to_internal_representation(_) do
    :help
  end

  defp validate(args) do
    args
    |> validate_project_root
  end

  defp validate_project_root({project_root, _} = args) do
    mix_file = Path.join(project_root, "mix.exs")
    is_mix_project = MyFile.is_directory(project_root) && MyFile.is_file(mix_file)

    if is_mix_project do
      args
    else
      IO.puts("invalid project root.")
      System.halt(0)
    end
  end
end
