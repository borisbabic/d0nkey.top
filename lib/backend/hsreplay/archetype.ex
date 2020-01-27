defmodule Backend.HSReplay.Archetype do
  use TypedStruct

  typedstruct enforce: true do
    field :id, integer
    field :name, String.t()
    # todo list them somewhere?
    field :player_class, integer
    # todo list them somewhere ?
    field :player_class_name, String.t()
    field :url, String.t()
    # not sure what the below two are for so I'm ignoring them
    # there is an as_of that might be interesting
    # field :standard_cpp_signature_core
    # field :wild_cpp_signature_core
  end

  def from_raw_map(map = %{"playerClass" => _}) do
    map
    |> Recase.Enumerable.convert_keys(&Recase.to_snake/1)
    |> from_raw_map()
  end

  def from_raw_map(%{
        "player_class" => pc,
        "player_class_name" => pcn,
        "url" => url,
        "name" => name,
        "id" => id
      }) do
    %__MODULE__{
      id: id,
      name: name,
      player_class: pc,
      player_class_name: pcn,
      url: url
    }
  end
end
