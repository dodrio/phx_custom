defmodule PhxCustom.File do
  def detect_type(path) do
    stat = File.lstat(path)

    cond do
      Path.extname(path) === ".eex" ->
        :eex

      {:ok, %File.Stat{type: type}} = stat ->
        type

      true ->
        :error
    end
  end

  def is_file(abs_path) do
    case File.lstat(abs_path) do
      {:ok, %File.Stat{type: :regular}} -> true
      _ -> false
    end
  end

  def is_directory(abs_path) do
    case File.lstat(abs_path) do
      {:ok, %File.Stat{type: :directory}} -> true
      _ -> false
    end
  end
end
