defmodule PhxCustom.Project do
  alias PhxCustom.Helper.File, as: MyFile

  def inspect(root) do
    type = get_project_type(root)
    project_name = get_project_name({type, root})
    project_name_camelcase = get_camelcase_project_name({type, root})
    path_web_app = get_path_web_app({type, project_name})
    path_web_lib = get_path_web_lib({type, project_name})
    path_web_router = get_path_web_router({type, project_name})
    path_web_assets = get_path_web_assets({type, project_name})
    path_web_statics = get_path_web_statics({type, project_name})
    path_ctx_app = get_path_ctx_app({type, project_name})
    module_web = "#{project_name_camelcase}Web"
    module_ctx = project_name_camelcase
    app_web = get_app_web({type, project_name})
    app_ctx = get_app_ctx({type, project_name})

    paths = %{
      web_app: path_web_app,
      web_lib: path_web_lib,
      web_router: path_web_router,
      web_assets: path_web_assets,
      web_statics: path_web_statics,
      ctx_app: path_ctx_app
    }

    [
      type: type,
      project_name: project_name,
      project_name_camelcase: project_name_camelcase,
      path: paths,
      module_web: module_web,
      module_ctx: module_ctx,
      app_web: app_web,
      app_ctx: app_ctx
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

  def get_path_web_app({:general, _project_name}) do
    ""
  end

  def get_path_web_app({:umbrella, project_name}) do
    "apps/#{project_name}_web"
  end

  def get_path_ctx_app({:general, _project_name}) do
    ""
  end

  def get_path_ctx_app({:umbrella, project_name}) do
    "apps/#{project_name}"
  end

  def get_path_web_lib({type, project_name}) do
    path_web_app = get_path_web_app({type, project_name})
    Path.join(path_web_app, "lib/#{project_name}_web")
  end

  def get_path_web_router({type, project_name}) do
    path_web_lib = get_path_web_lib({type, project_name})
    Path.join(path_web_lib, "router.ex")
  end

  def get_path_web_assets({type, project_name}) do
    path_web_app = get_path_web_app({type, project_name})
    Path.join(path_web_app, "assets")
  end

  def get_path_web_statics({type, project_name}) do
    path_web_app = get_path_web_app({type, project_name})
    Path.join(path_web_app, "priv/static")
  end

  def get_app_web({:general, project_name}) do
    project_name
  end

  def get_app_web({:umbrella, project_name}) do
    "#{project_name}_web"
  end

  def get_app_ctx({_, project_name}) do
    project_name
  end
end
