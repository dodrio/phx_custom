defmodule PhxCustom.Reporter do
  alias PhxCustom.Helper.File, as: MyFile

  def report(file_path, bindings) do
    content =
      case MyFile.detect_type(file_path) do
        :eex ->
          EEx.eval_file(file_path, bindings)

        :regular ->
          File.read!(file_path)
      end

    IO.puts("")
    IO.ANSI.Docs.print(content, "text/markdown")
  end
end
