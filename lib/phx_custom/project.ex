defmodule PhxCustom.Project do
  alias PhxCustom.File, as: MyFile

  def inspect(root) do
    type = get_project_type(root)
    project_name = get_project_name({type, root})
    camelcase_project_name = get_camelcase_project_name({type, root})
    web_root = get_web_root({type, project_name})
    router_path = get_router_path({type, project_name})

    [
      type: type,
      project_name: project_name,
      camelcase_project_name: camelcase_project_name,
      web_root: web_root,
      router_path: router_path,
      module_web: "#{camelcase_project_name}Web"
    ]
  end

  def get_project_type(root) do
    is_umbrella_project =
      File.ls!(root)
      |> Enum.map(&Path.expand(&1, root))
      |> Enum.filter(&MyFile.is_directory/1)
      |> Enum.any?(&(Path.basename(&1) === "apps"))

    if is_umbrella_project do
      :umbrella
    else
      :general
    end
  end

  def get_project_name({:general, root}) do
    Path.join(root, "lib")
    |> File.ls!()
    |> Enum.find_value(&extract_project_name/1)
  end

  def get_project_name({:umbrella, root}) do
    Path.join(root, "apps")
    |> File.ls!()
    |> Enum.find_value(&extract_project_name/1)
  end

  defp extract_project_name(name) do
    case Regex.run(~r/(.*)_web/, name, capture: :all_but_first) do
      [project_name] -> project_name
      _ -> nil
    end
  end

  def get_camelcase_project_name({_, root}) do
    main_module = Path.join(root, "mix.exs")

    File.stream!(main_module)
    |> Enum.at(0)
    |> extract_camelcase_project_name()
  end

  defp extract_camelcase_project_name(line) do
    case Regex.run(~r/defmodule (.*?)\..*/, line, capture: :all_but_first) do
      [module_name] -> module_name
      _ -> nil
    end
  end

  def get_web_root({:general, _project_name}) do
    "."
  end

  def get_web_root({:umbrella, project_name}) do
    "apps/#{project_name}_web"
  end

  def get_router_path({:general, project_name}) do
    "lib/#{project_name}_web/router.ex"
  end

  def get_router_path({:umbrella, project_name}) do
    "#{get_web_root({:umbrella, project_name})}/lib/#{project_name}_web/router.ex"
  end
end
