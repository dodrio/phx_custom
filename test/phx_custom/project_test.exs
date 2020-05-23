defmodule PhxCustomTest.Project do
  use ExUnit.Case
  doctest PhxCustom.Project

  alias PhxCustom.Project

  describe "inspect" do
    test "works with general project" do
      root = Path.expand("../../priv/example-projects/foo_bar", __DIR__)

      assert Project.inspect(root) === [
               type: :general,
               project_name: "foo_bar",
               project_name_camelcase: "FooBar",
               path: %{
                 ctx_app: "",
                 web_app: "",
                 web_assets: "assets",
                 web_lib: "lib/foo_bar_web",
                 web_router: "lib/foo_bar_web/router.ex",
                 web_statics: "priv/static"
               },
               module_web: "FooBarWeb",
               module_ctx: "FooBar",
               app_web: "foo_bar",
               app_ctx: "foo_bar"
             ]
    end

    test "works with umbrella project" do
      root = Path.expand("../../priv/example-projects/foo_bar_umbrella", __DIR__)

      assert Project.inspect(root) === [
               type: :umbrella,
               project_name: "foo_bar",
               project_name_camelcase: "FooBar",
               path: %{
                 ctx_app: "apps/foo_bar",
                 web_app: "apps/foo_bar_web",
                 web_assets: "apps/foo_bar_web/assets",
                 web_lib: "apps/foo_bar_web/lib/foo_bar_web",
                 web_router: "apps/foo_bar_web/lib/foo_bar_web/router.ex",
                 web_statics: "apps/foo_bar_web/priv/static"
               },
               module_web: "FooBarWeb",
               module_ctx: "FooBar",
               app_web: "foo_bar_web",
               app_ctx: "foo_bar"
             ]
    end
  end
end
