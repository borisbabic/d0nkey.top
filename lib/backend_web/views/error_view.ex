defmodule BackendWeb.ErrorView do
  use BackendWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  def render("500.html", _assigns) do
    internal_server(%{})
  end

  def internal_server(assigns) do
    ~H"""
    <h2>
      Oops, looks like something went wrong...
    </h2>
    <div>
      If you think it should have went right, and the issue persists, please report it in one of the following places:
      <ul>
        <li><a href={Constants.discord_bugs()}>Discord</a></li>
        <li><a href={Constants.github_issues()}>Github</a></li>
      </ul>
    </div>
    """
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
