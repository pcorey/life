defmodule Interface.PageController do
  use Interface.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
