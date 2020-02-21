defmodule <%= @module_web %>.App.PageController do
  use <%= @module_web %>, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
