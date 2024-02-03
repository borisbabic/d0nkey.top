defmodule BackendWeb.FunView do
  use BackendWeb, :view

  def render("wild.html", _) do
    wild(%{})
  end

  def wild(assigns) do
    ~H"""
      <h4 class="title is-4">Is wild broken?</h4>
      <br>
      <h1 class="title is-1">Yes</h1>
    """
  end
end
