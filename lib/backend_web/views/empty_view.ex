defmodule BackendWeb.EmptyView do
  use BackendWeb, :view

  def render("with_nav.html", _), do: ""
end
