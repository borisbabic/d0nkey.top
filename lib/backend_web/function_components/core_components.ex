defmodule FunctionComponents.CoreComponents do
  @moduledoc false
  use Phoenix.Component
  # alias Phoenix.LiveView.JS

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
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div>
      <label class="">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class=""
          {@rest}
        />
        {@label}
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(_assigns) do
    raise "not implemented"
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

  def error(assigns) do
    ~H"""
    <p class="notification is-error">
      {render_slot(@inner_block)}
    </p>
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
  # attr :id, :string, required: true
  # attr :rest, :global

  slot :trigger, validate_attrs: false
  slot :panel, validate_attrs: false

  @spec accordion(Socket.assigns()) :: Rendered.t()
  def accordion(assigns) do
    ~H"""
    <div class="tw-rounded tw-w-full tw-divide-y tw-divide-outline tw-overflow-hidden tw-rounded-radius tw-border tw-border-outline tw-bg-surface-alt/40 tw-text-on-surface tw-dark:divide-outline-dark tw-dark:border-outline-dark tw-dark:bg-surface-dark-alt/50 tw-dark:text-on-surface-dark">
        <%= for {trigger, panel} <- @trigger |> Enum.zip(@panel) do %>
            <div x-data="{ isExpanded: false }">
                <button id="controlsAccordionItemOne" type="button" class="tw-flex tw-w-full tw-items-center tw-justify-between tw-gap-4 tw-bg-surface-alt tw-p-4 tw-text-left tw-underline-offset-2 tw-hover:bg-surface-alt/75 tw-focus-visible:bg-surface-alt/75 tw-focus-visible:underline tw-focus-visible:outline-hidden tw-dark:bg-surface-dark-alt tw-dark:hover:bg-surface-dark-alt/75 tw-dark:focus-visible:bg-surface-dark-alt/75" aria-controls="accordionItemOne" x-on:click="isExpanded = ! isExpanded" x-bind:class="isExpanded ? 'text-on-surface-strong dark:text-on-surface-dark-strong font-bold'  : 'text-on-surface dark:text-on-surface-dark font-medium'" x-bind:aria-expanded="isExpanded ? 'true' : 'false'">
                    <%= render_slot(trigger) %>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke="currentColor" class="tw-size-5 tw-shrink-0 tw-transition" aria-hidden="true" x-bind:class="isExpanded  ?  'rotate-180'  :  ''">
                       <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5"/>
                    </svg>
                </button>
                <div x-cloak x-show="isExpanded" id="accordionItemOne" role="region" aria-labelledby="controlsAccordionItemOne" x-collapse>
                    <div class="tw-p-4">
                        <%= render_slot(panel) %>
                    </div>
                </div>
            </div>
        <% end %>
    </div>
    """
  end
end
