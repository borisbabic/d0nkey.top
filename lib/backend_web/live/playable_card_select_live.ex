defmodule BackendWeb.PlayableCardSelectLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout
  alias Components.Filter.PlayableCardSelect
  data(base_url, :string)
  data(update_fun, :fun)
  data(prefix, :string)
  data(title, :string)
  data(selected, :list)

  def mount(
        _params,
        %{"base_url" => base_url, "prefix" => prefix, "selected" => selected} = sesssion,
        socket
      ) do
    update_fun = create_update_fun(base_url, prefix)

    {:ok,
     assign(socket,
       selected: selected,
       prefix: prefix,
       update_fun: update_fun,
       base_url: base_url,
       title: Map.get(sesssion, "title")
     )}
  end

  def render(assigns) do
    ~F"""
    <PlayableCardSelect update_fun={@update_fun} id="playable_card_select" selected={@selected} title={@title}/>
    """
  end

  def create_update_fun(base_url, prefix) do
    fn
      selected ->
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
        {:redirect, to: new_url}
    end
  end
end
