defmodule BackendWeb.PeriodHTML do
  use BackendWeb, :html

  use Phoenix.HTML

  import Torch.TableView
  import Torch.FilterView
  import Torch.Component

  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, Torch.Component.translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  embed_templates "period_html/*"
end
