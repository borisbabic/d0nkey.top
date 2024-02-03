defmodule BackendWeb.AuthView do
  require Logger
  use BackendWeb, :view

  def render("login_welcome.html", %{user: user}) do
    login_success(%{user: user})
  end

  def render("user_expected.html", _) do
    user_expected(%{})
  end

  def login_success(assigns) do
    ~H"""
    Login success! Welcome {User.display_name(@user)}
    """
  end

  def user_expected(assigns) do
    ~H"""
    Weird, you're not supposed to see this unless you're logged in. Who are you?
    """
  end
end
