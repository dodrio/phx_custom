defmodule PhxCustomTest.Project do
  use ExUnit.Case
  doctest PhxCustom.Project

  alias PhxCustom.Project

  describe "get_project_type" do
    test "works with general project" do
      root = Path.expand("../../priv/example-projects/foo_bar", __DIR__)
      assert Project.get_project_type(root) === :general
    end

    test "works with umbrella project" do
      root = Path.expand("../../priv/example-projects/foo_bar_umbrella", __DIR__)
      assert Project.get_project_type(root) === :umbrella
    end
  end

  describe "get_project_name" do
    test "works with general project" do
      root = Path.expand("../../priv/example-projects/foo_bar", __DIR__)
      assert Project.get_project_name({:general, root}) === "foo_bar"
    end

    test "works with umbrella project" do
      root = Path.expand("../../priv/example-projects/foo_bar_umbrella", __DIR__)
      assert Project.get_project_name({:umbrella, root}) === "foo_bar"
    end
  end

  describe "get_camelcase_project_name" do
    test "works with general project" do
      root = Path.expand("../../priv/example-projects/foo_bar", __DIR__)
      assert Project.get_camelcase_project_name({:general, root}) === "FooBar"
    end

    test "works with umbrella project" do
      root = Path.expand("../../priv/example-projects/foo_bar_umbrella", __DIR__)
      assert Project.get_camelcase_project_name({:umbrella, root}) === "FooBar"
    end
  end

  describe "inspect" do
    test "works with general project" do
      root = Path.expand("../../priv/example-projects/foo_bar", __DIR__)

      assert Project.inspect(root) === [
               type: :general,
               project_name: "foo_bar",
               camelcase_project_name: "FooBar",
               web_root: ".",
               router_path: "lib/foo_bar_web/router.ex",
               module_web: "FooBarWeb"
             ]
    end

    test "works with umbrella project" do
      root = Path.expand("../../priv/example-projects/foo_bar_umbrella", __DIR__)

      assert Project.inspect(root) === [
               type: :umbrella,
               project_name: "foo_bar",
               camelcase_project_name: "FooBar",
               web_root: "apps/foo_bar_web",
               router_path: "apps/foo_bar_web/lib/foo_bar_web/router.ex",
               module_web: "FooBarWeb"
             ]
    end
  end
end
