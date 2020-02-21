defmodule FooBarWeb.PageController do
  use FooBarWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
