defmodule BackendWeb.ViewUtil do
  @moduledoc false
  use BackendWeb, :view

  @type pagination ::
          %{
            dropdown: {
              [%{selected: boolean, display: String.t(), link: String.t()}],
              String.t()
            },
            offset: integer,
            limit: integer,
            prev_button: any(),
            next_button: any()
          }

  @default_pagination_opts %{
    default_limit: 50,
    default_offset: 0,
    dropdown_title: "Page Size",
    limit_options: [
      10,
      20,
      30,
      50,
      75,
      100,
      250,
      500
    ]
  }

  def prev_button(_, prev_offset, offset) when prev_offset == offset do
    ~E"""
    <span class="button is-link">
        <i class="fas fa-caret-left"></i>
    </span>
    """
  end

  def prev_button(update_link, prev_offset, _) do
    link = update_link.(%{"offset" => prev_offset})

    ~E"""
    <a class="button is-link" href="<%= link %>">
      <i class="fas fa-caret-left"></i>
    </a>
    """
  end

  def next_button(update_link, next_offset) do
    link = update_link.(%{"offset" => next_offset})

    ~E"""
    <a class="button is-link" href="<%= link %>">
      <i class="fas fa-caret-right"></i>
    </a>
    """
  end

  def get_surrounding(offset, limit) when is_integer(offset) and is_integer(limit),
    do: {(offset - limit) |> max(0), offset + limit}

  def get_surrounding(offset, limit),
    do: get_surrounding(Util.to_int_or_orig(offset), Util.to_int_or_orig(limit))

  def handle_pagination(pagination, update_link, opts \\ []) do
    options = Enum.into(opts, @default_pagination_opts)
    limit = pagination["limit"] |> Util.to_int_or_orig() || options.default_limit
    offset = pagination["offset"] |> Util.to_int_or_orig() || options.default_offset
    {prev_offset, next_offset} = get_surrounding(offset, limit)

    dropdown_options =
      options.limit_options
      |> Enum.map(fn l ->
        %{
          link: update_link.(%{"limit" => l}),
          selected: l == limit,
          display: "Show #{l}"
        }
      end)

    %{
      offset: offset,
      limit: limit,
      dropdown: {dropdown_options, options.dropdown_title},
      prev_button: prev_button(update_link, prev_offset, offset),
      next_button: next_button(update_link, next_offset)
    }
  end
end
