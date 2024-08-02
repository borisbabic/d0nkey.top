defmodule BackendWeb.LiveHelpers do
  import Phoenix.Component, only: [assign: 3, assign: 2, assign_new: 3]
  alias Phoenix.LiveView.Socket

  @spec assign_defaults(Socket.t(), any()) :: Socket.t()
  def assign_defaults(socket, session) do
    socket
    |> assign_new(:user, fn ->
      load_user(session)
    end)
  end

  alias Backend.UserManager.User
  alias Backend.UserManager.Guardian

  @spec load_user(Map.t() | any) :: User | nil
  def load_user(%{"guardian_default_token" => token}) do
    token
    |> Guardian.resource_from_token()
    |> case do
      {:ok, user, _} -> user
      _ -> nil
    end
  end

  def load_user(_), do: nil

  @spec assign_meta_tags(Socket.t(), Map.t()) :: Socket.t()
  def assign_meta_tags(socket, new_tags = %{}) do
    meta = (get_in(socket.assigns, [:meta_tags]) || %{}) |> Map.merge(new_tags)
    socket |> assign(:meta_tags, meta)
  end

  @doc """
  Ensures that the socket has a stream.
  Returns the socket unchanged if present
  IF not initializes the stream with `init`
  """
  @spec ensure_stream(Socket.t(), atom(), boolean(), list() | any()) :: Socket.t()
  def ensure_stream(socket, stream_name, reset \\ false, init \\ []) do
    if Map.has_key?(socket.assigns, stream_name) do
      socket
    else
      Phoenix.LiveView.stream(socket, stream_name, init, reset: reset)
    end
  end

  @spec handle_offset_stream_scroll(
          Socket.t(),
          atom(),
          list(),
          integer(),
          integer(),
          integer() | nil,
          boolean()
        ) :: Socket.t()
  def handle_offset_stream_scroll(
        socket,
        stream_name,
        stream_items,
        new_offset,
        old_offset,
        viewport_size,
        reset \\ false
      ) do
    {items, at, limit} =
      if new_offset >= old_offset do
        {stream_items, -1, viewport_size && viewport_size * -1}
      else
        {Enum.reverse(stream_items), 0, viewport_size && viewport_size}
      end

    case items do
      [] ->
        assign(socket, end_of_stream?: true) |> ensure_stream(stream_name, reset)

      [_ | _] = items ->
        base_stream_opts = [at: at, reset: reset]

        stream_opts =
          if limit do
            [{:limit, limit} | base_stream_opts]
          else
            base_stream_opts
          end

        socket
        |> assign(end_of_stream?: false)
        |> assign(:offset, new_offset)
        |> Phoenix.LiveView.stream(stream_name, items, stream_opts)
    end
  end
end
