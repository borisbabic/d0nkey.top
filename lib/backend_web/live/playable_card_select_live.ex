defmodule BackendWeb.PlayableCardSelectLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout
  alias Components.Filter.PlayableCardSelect
  data(base_url, :string)
  data(param, :string)
  data(title, :string)
  data(selected, :list)

  def mount(
        _params,
        %{"param" => param, "selected" => selected, "base_url" => base_url} = session,
        socket
      ) do
    {:ok,
     assign(socket,
       selected: selected,
       param: param,
       base_url: base_url,
       updater: create_update_fun(base_url, param),
       title: Map.get(session, "title")
     )}
  end

  def render(assigns) do
    ~F"""
    <PlayableCardSelect updater={@updater} param={@param} id={"playable_card_select_#{@param}"} selected={@selected || %{}} title={@title}/>
    """
  end

  def create_update_fun(base_url, prefix) do
    fn
      socket, selected ->
        uri = URI.parse(base_url)
        old_query_map = (uri.query || "") |> URI.decode_query()

        other_query_params =
          old_query_map
          |> Map.reject(fn {key, _value} ->
            is_binary(key) and String.starts_with?(key, prefix)
          end)

        new_query_map =
          for id <- selected, into: other_query_params do
            {"#{prefix}[#{id}]", true}
          end

        new_query = URI.encode_query(new_query_map)
        new_url = Map.put(uri, :query, new_query) |> to_string()
        redirect(socket, to: new_url)
    end
  end
end
