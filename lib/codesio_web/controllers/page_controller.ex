defmodule CodesioWeb.PageController do
  use CodesioWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout("admin.html")
    |> render("index.html")
  end

  def test(conn, _params) do
    render conn, "test.html"
  end
end
