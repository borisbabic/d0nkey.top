defmodule FunctionComponents.CoreComponents do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: BackendWeb.Gettext
  import FunctionComponents.Table
  alias Phoenix.LiveView.JS

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as radio, are best
  written directly in your templates.

  ## Examples

  ```heex
  <.input field={@form[:email]} type="email" />
  <.input name="my-input" errors={["oh no!"]} />
  ```

  ## Select type

  When using `type="select"`, you must pass the `options` and optionally
  a `value` to mark which option should be preselected.

  ```heex
  <.input field={@form[:user_type]} type="select" options={["Admin": "admin", "User": "user"]} />
  ```

  For more information on what kind of data can be passed to `options` see
  [`options_for_select`](https://phoenix-html.hexdocs.pm/Phoenix.HTML.Form.html#options_for_select/2).
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :any, default: nil, doc: "the input class to use over defaults"
  attr :error_class, :any, default: nil, doc: "the input error class to use over defaults"

  attr :rest, :global, include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error/1))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="tw-mb-4">
      <label for={@id} class="tw-inline-flex tw-items-center tw-gap-3 tw-cursor-pointer tw-select-none">
        <input
          type="hidden"
          name={@name}
          value="false"
          disabled={@rest[:disabled]}
          form={@rest[:form]}
        />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={@class || "tw-rounded tw-bg-[#2a2a2a] tw-border-slate-700 tw-text-sky-500 focus:tw-ring-sky-500/30 tw-w-4 tw-h-4 tw-transition-all"}
          {@rest}
        />
        <span :if={@label} class="tw-text-sm tw-font-medium text-white">{@label}</span>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="tw-mb-4">
      <label for={@id} class="tw-block">
        <span :if={@label} class="tw-block tw-text-sm tw-font-bold text-white tw-mb-1.5">{@label}</span>
        <div class="tw-relative">
          <select
            id={@id}
            name={@name}
            class={[
              @class || "tw-w-full tw-appearance-none tw-rounded-lg tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-text-white focus:tw-border-sky-500 focus:tw-ring-2 focus:tw-ring-sky-500/20 tw-h-10 tw-pl-3 tw-pr-10 tw-text-sm tw-transition-all tw-cursor-pointer",
              @errors != [] && (@error_class || "tw-border-rose-500 focus:tw-border-rose-500 focus:tw-ring-rose-500/20")
            ]}
            multiple={@multiple}
            {@rest}
          >
            <option :if={@prompt} value="">{@prompt}</option>
            {Phoenix.HTML.Form.options_for_select(@options, @value)}
          </select>
          
          <div :if={!@multiple} class="tw-pointer-events-none tw-absolute tw-inset-y-0 tw-right-0 tw-flex tw-items-center tw-pr-3 tw-text-slate-400">
            <svg class="tw-h-4 tw-w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 0 1 1.06 0L10 11.94l3.72-3.72a.75.75 0 1 1 1.06 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L5.22 9.28a.75.75 0 0 1 0-1.06z" clip-rule="evenodd" />
            </svg>
          </div>
        </div>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="tw-mb-4">
      <label for={@id} class="tw-block">
        <span :if={@label} class="tw-block tw-text-sm tw-font-bold text-white tw-mb-1.5">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={[
            @class || "tw-w-full tw-rounded-lg tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-text-white focus:tw-border-sky-500 focus:tw-ring-2 focus:tw-ring-sky-500/20 tw-p-3 tw-text-sm tw-min-h-[100px] tw-transition-all",
            @errors != [] && (@error_class || "tw-border-rose-500 focus:tw-border-rose-500 focus:tw-ring-rose-500/20")
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class="tw-mb-4">
      <label for={@id} class="tw-block">
        <span :if={@label} class="tw-block tw-text-sm tw-font-bold text-white tw-mb-1.5">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class || "tw-w-full tw-rounded-lg tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-text-white focus:tw-border-sky-500 focus:tw-ring-2 focus:tw-ring-sky-500/20 tw-h-10 tw-px-3 tw-text-sm tw-transition-all",
            @errors != [] && (@error_class || "tw-border-rose-500 focus:tw-border-rose-500 focus:tw-ring-rose-500/20")
          ]}
          {@rest}
        />
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a smooth toggle switch instead of a classic checkbox.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :checked, :boolean, default: false
  attr :field, Phoenix.HTML.FormField
  attr :rest, :global

  def toggle(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", field.value) end)
    |> toggle()
  end

  def toggle(assigns) do
    ~H"""
    <div class="tw-mb-4">
      <label for={@id} class="tw-inline-flex tw-items-center tw-justify-between tw-w-full tw-cursor-pointer tw-select-none">
        <span :if={@label} class="tw-text-sm tw-font-medium text-white">{@label}</span>
        
        <div class="tw-relative tw-inline-block">
          <input
            type="hidden"
            name={@name}
            value="false"
            disabled={@rest[:disabled]}
            form={@rest[:form]}
          />
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            class="tw-sr-only tw-peer"
            {@rest}
          />
          <div class="tw-w-11 tw-h-6 tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-full peer-checked:tw-bg-sky-500 peer-checked:tw-border-transparent tw-transition-all"></div>
          <div class="tw-absolute tw-top-1 tw-left-1 tw-bg-slate-400 tw-w-4 tw-h-4 tw-rounded-full peer-checked:tw-bg-white peer-checked:tw-translate-x-5 tw-transition-all"></div>
        </div>
      </label>
    </div>
    """
  end

  slot :inner_block, required: true, doc: "the filters"

  def filter_container(assigns) do
    ~H"""
      <div class="tw-space-y-2">
        <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-2">
          {render_slot(@inner_block)}
        </div>
      </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash
        id="welcome-back"
        kind={:info}
        phx-mounted={show("#welcome-back") |> JS.remove_attribute("hidden")}
        hidden
      >
        Welcome Back!
      </.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="toast toast-top toast-end z-50"
      {@rest}
    >
      <div class={[
        "alert w-80 sm:w-96 max-w-80 sm:max-w-96 text-wrap",
        @kind == :info && "alert-info",
        @kind == :error && "alert-error"
      ]}>
        <.icon :if={@kind == :info} name="hero-information-circle" class="size-5 shrink-0" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle" class="size-5 shrink-0" />
        <div>
          <p :if={@title} class="font-semibold">{@title}</p>
          <p>{msg}</p>
        </div>
        <div class="flex-1" />
        <button type="button" class="group self-start cursor-pointer" aria-label={gettext("close")}>
          <.icon name="hero-x-mark" class="size-5 opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(BackendWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BackendWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true
  # Helper used by inputs to generate form errors
  def error(assigns) do
    ~H"""
    <p class="mt-1.5 flex gap-2 items-center text-sm text-error">
      <.icon name="hero-exclamation-circle" class="size-5" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in `assets/vendor/heroicons.js`.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  @doc """
  Accordion components allows users to show and hide sections of related panel on a page.

  ## Examples

  ```heex
  <.accordion>
    <:trigger>Accordion</:trigger>
    <:panel>Content</:panel>
  </.accordion>
  ```
  """

  # attr :class, :any, doc: "Extend existing component styles"
  # attr :controlled, :boolean, default: false
  attr :id, :string, default: "accordion"
  # attr :rest, :global

  slot :trigger, validate_attrs: false
  slot :panel, validate_attrs: false

  @spec accordion(Socket.assigns()) :: Rendered.t()
  def accordion(assigns) do
    ~H"""
    <div class="tw-rounded tw-w-full tw-divide-y tw-divide-outline tw-overflow-hidden tw-rounded-radius tw-border tw-border-outline tw-bg-surface-alt/40 tw-text-on-surface tw-dark:divide-outline-dark tw-dark:border-outline-dark tw-dark:bg-surface-dark-alt/50 tw-dark:text-on-surface-dark">
        <%= for {{trigger, panel}, index} <- @trigger |> Enum.zip(@panel) |> Enum.with_index() do %>
            <div x-data="{ isExpanded: false }">
                <button id={"controlsAccordionItem-#{@id}-#{index}"} type="button" class="tw-flex tw-w-full tw-items-center tw-justify-between tw-gap-4 tw-bg-surface-alt tw-p-4 tw-text-left tw-underline-offset-2 tw-hover:bg-surface-alt/75 tw-focus-visible:bg-surface-alt/75 tw-focus-visible:underline tw-focus-visible:outline-hidden tw-dark:bg-surface-dark-alt tw-dark:hover:bg-surface-dark-alt/75 tw-dark:focus-visible:bg-surface-dark-alt/75" aria-controls={"accordionItem-#{@id}-#{index}"} x-on:click="isExpanded = ! isExpanded" x-bind:class="isExpanded ? 'text-on-surface-strong dark:text-on-surface-dark-strong font-bold'  : 'text-on-surface dark:text-on-surface-dark font-medium'" x-bind:aria-expanded="isExpanded ? 'true' : 'false'">
                    <%= render_slot(trigger) %>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke="currentColor" class="tw-size-5 tw-shrink-0 tw-transition" aria-hidden="true" x-bind:class="isExpanded  ?  'rotate-180'  :  ''">
                       <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5"/>
                    </svg>
                </button>
                <div x-cloak x-show="isExpanded" id={"accordionItem-#{@id}-#{index}"} role="region" aria-labelledby={"controlsAccordionItem-#{@id}-#{index}"} x-collapse>
                    <div class="tw-p-4">
                        <%= render_slot(panel) %>
                    </div>
                </div>
            </div>
        <% end %>
    </div>
    """
  end

  attr :show_footer, :boolean, default: true
  attr :show_error, :boolean, default: false

  attr :title, :string, default: nil
  attr :show_body, :boolean, default: true
  attr :show_cancel_button, :boolean, default: true

  attr :error_message, :string, default: "Error"
  attr :cancel_button_message, :string, default: "Cancel"

  slot :background, required: false
  slot :footer, required: false
  slot :inner_block, required: true
  attr :id, :string, required: true

  def modal(assigns) do
    ~H"""
        <div id={@id} class="modal">
          <div class="modal-background">{render_slot(@background)}</div>
          <div class="modal-card !tw-max-h-[85dvh]">
            <header class="modal-card-head" :if={@title}>
                <p class="modal-card-title">{@title}</p>
                <button class="delete" type="button" aria-label="close" phx-click={hide_modal(@id)}></button>
            </header>
            <section :if={@show_body} class={"modal-card-body"}>
              {render_slot(@inner_block)}
            </section>
            <footer :if={@show_footer} class="modal-card-foot">
              {render_slot(@footer)}
              <button :if={@show_cancel_button} class="button" type="button" phx-click={hide_modal(@id)}>{@cancel_button_message}</button>
              <div :if={@show_error} class="notification is-warning tag">{@error_message}</div>
            </footer>
          </div>
        </div>
    """
  end

  @doc """
  Renders alert banners using Bulma contextual color modes.
  """
  attr :type, :string, default: "warning", values: ["warning", "info", "success", "danger"]
  attr :title, :string, default: nil
  slot :inner_block, required: true

  def alert(assigns) do
    ~H"""
    <div class={"tw-flex tw-items-start tw-gap-3 tw-rounded-xl tw-p-4 tw-border has-background-dark tw-border-#{@type}/30"}>
      <div class={"has-text-#{@type} tw-mt-0.5"}>
        <HeroIcons.warning_triangle class="tw-w-5 tw-h-5" />
      </div>
      <div>
        <h3 :if={@title} class={"tw-text-sm tw-font-semibold has-text-#{@type}"}><%= @title %></h3>
        <p class="tw-mt-1 tw-text-sm tw-text-slate-300">
          <%= render_slot(@inner_block) %>
        </p>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  def code(assigns) do
    ~H"""
      <code class="tw-block tw-text-xs tw-bg-black/40 tw-p-1.5 tw-rounded has-text-info tw-border tw-border-slate-800/60">
        <%= render_slot(@inner_block) %>
      </code>
    """
  end

  @doc """
  Renders a system-wide dark data table. Supports responsive styling, 
  precise tooltip alignment anchoring, and conditional columns.
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_class, :any, default: nil

  slot :col, required: true do
    attr :label, :any, required: true
    attr :class, :string, doc: "Applies to both th and td elements"
    attr :header_class, :string, doc: "Applies exclusively to th elements"
    attr :cell_class, :string, doc: "Applies exclusively to td elements"
  end

  def data_table(assigns) do
    ~H"""
    <.table>
      <.thead>
        <.trh>
          <.th 
            :for={col <- @col} 
            class={[
              col[:class], 
              col[:header_class]
            ]}
          >
            {col[:label]}
          </.th>
        </.trh>
      </.thead>
        <.tbody >
          <.trb
            :for={row <- @rows} 
            class={[
              is_function(@row_class) && @row_class.(row),
              is_binary(@row_class) && @row_class
            ]}
          >
            <.td 
              :for={col <- @col} 
              class={[
                col[:class], 
                col[:cell_class]
              ]}
            >
              {render_slot(col, row)}
            </.td>
          </.trb>
        </.tbody>
    </.table>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """

  Returns the JS object with the modal displayed and focused.

  ## Parameters

  - js - an optional composable JS script to be executed.
  - id - The id of the modal to be shown.

  ## Description
   Updates the specified modal's state to open and focuses on its first content element.

  """
  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.add_class("is-active", to: "##{id}")
    |> JS.focus_first(to: "##{id}")
  end

  @doc """

  Returns the updated JavaScript state with the modal closed.

  ## Parameters

  - js - an optional composable JS script to be executed.
  - id - The id of the modal to be hidden.

  ## Description
  Removes the "open" attribute from the specified modal and sets the focus away from it.

  """
  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.remove_class("is-active", to: "##{id}")
    |> JS.pop_focus()
  end
end
