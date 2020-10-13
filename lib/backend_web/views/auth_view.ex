defmodule BackendWeb.AuthView do
  require Logger
  use BackendWeb, :view
  alias Backend.UserManager.User

  def render("login_welcome.html", %{user: user}) do
    ~E"""
    Login success! Welcome <%= User.display_name(user) %>
    """
  end

  def render("user_expected.html", _) do
    ~E"""
    Weird, you're not supposed to see this unless you're logged in. Who are you?
    """
  end
end
