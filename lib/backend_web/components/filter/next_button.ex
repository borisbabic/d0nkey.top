defmodule Components.Filter.NextButton do
  @moduledoc false
  use BackendWeb, :surface_component
  use Components.Filter.Context

  prop(default_offset, :integer, default: 0)
  prop(default_limit, :integer, default: 20)

  def render(assigns) do
    ~F"""
    <.link  class="button is-link" patch={link(@live_view, @path_params, @url_params, @default_offset, @default_limit)}>
        <HeroIcons.chevron_right />
    </.link>
    """
  end

  def link(live_view, path_params, url_params, default_offset, default_limit) do
    old_offset = Util.to_int(url_params["offset"], default_offset)
    limit = Util.to_int(url_params["limit"], default_limit)
    new_offset = old_offset + limit
    new_params = Components.LivePatchDropdown.update_params(url_params, "offset", new_offset)
    Components.LivePatchDropdown.link(BackendWeb.Endpoint, live_view, path_params, new_params)
  end
end
