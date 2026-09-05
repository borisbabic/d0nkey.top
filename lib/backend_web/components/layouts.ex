defmodule BackendWeb.Layouts do
  use BackendWeb, :html
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.
  """
  slot :inner_block, required: true
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"

  def app(assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    {render_slot(@inner_block)}
    """
  end

  @doc """
  Renders flash notices (info, error, success, warning, and connection states).
  """
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :class, :any, default: nil, doc: "custom classes for the flash container"

  def flash_group(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="FlashGroup"
      class={[
        "tw-fixed tw-top-[4.75rem] tw-right-4 tw-z-50 tw-flex tw-flex-col tw-gap-2.5 tw-w-[calc(100vw-2rem)] sm:tw-w-96 tw-pointer-events-none",
        @class
      ]}
      aria-live="polite"
    >
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
      <.flash kind={:success} flash={@flash} />
      <.flash kind={:warning} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        timeout={nil}
        title={gettext("Connection lost")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        <span class="tw-inline-flex tw-items-center tw-gap-2">
          <svg class="tw-animate-spin tw-size-4 tw-shrink-0" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="tw-opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="tw-opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {gettext("Attempting to reconnect...")}
        </span>
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        timeout={nil}
        title={gettext("Something went wrong")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        <span class="tw-inline-flex tw-items-center tw-gap-2">
          <svg class="tw-animate-spin tw-size-4 tw-shrink-0" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="tw-opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="tw-opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {gettext("Hang in there while we get back on track...")}
        </span>
      </.flash>
    </div>
    """
  end
end
