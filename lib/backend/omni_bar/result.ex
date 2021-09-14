defmodule OmniBar.Result do
  @moduledoc "A result a provider produces for a search"
  use TypedStruct

  typedstruct enforce: true do
    # included so that the originating search can know that the result isn't obsolete
    field :search_term, :string
    field :display_value, :string
    field :priority, :integer
    field :link, :string
    field :result_id, :string
  end
end
