defmodule PhxCustom.Generator do
  alias PhxCustom.File, as: MyFile

  def copy_file(src, dest) do
    copy({:regular, src, dest})
  end

  def copy_file(src, dest, assigns) do
    copy({:regular, src, dest}, assigns)
  end

  def copy_dir(src_dir, dest_dir) do
    generate_copy_dir_operations(src_dir, dest_dir)
    |> Enum.each(&copy(&1))
  end

  def copy_dir(src_dir, dest_dir, assigns) do
    generate_copy_dir_operations(src_dir, dest_dir)
    |> Enum.each(&copy(&1, assigns))
  end

  def delete(wildcards) do
    wildcards
    |> Enum.map(&Path.wildcard(&1))
    |> List.flatten()
    |> Enum.each(fn path ->
      log(:red, :deleting, Path.relative_to_cwd(path))
      File.rm_rf!(path)
    end)
  end

  defp generate_copy_dir_operations(src_dir, dest_dir) do
    Path.wildcard("#{src_dir}/**/*")
    |> Enum.map(fn path ->
      type = MyFile.detect_type(path)

      src = path

      dest =
        path
        |> Path.relative_to(src_dir)
        |> Path.expand(dest_dir)

      {type, src, dest}
    end)
  end

  defp copy({:regular, src, dest}) do
    Mix.Generator.copy_file(src, dest)
  end

  defp copy({:eex, src, dest}) do
    Mix.Generator.copy_file(src, dest)
  end

  defp copy(_) do
  end

  defp copy({:regular, src, dest}, assigns) do
    try do
      Mix.Generator.copy_template(src, dest, assigns)
    rescue
      UnicodeConversionError ->
        Mix.Generator.copy_file(src, dest)
    end
  end

  defp copy({:eex, src, dest}, _assigns) do
    Mix.Generator.copy_file(src, dest)
  end

  defp copy(_, _assigns) do
  end

  # copy from https://github.com/elixir-lang/elixir/blob/79388035f5391f0a283a48fba792ae3b4f4b5f21/lib/mix/lib/mix/generator.ex#L153
  defp log(color, command, message, opts \\ []) do
    unless opts[:quiet] do
      Mix.shell().info([color, "* #{command} ", :reset, message])
    end
  end
end
