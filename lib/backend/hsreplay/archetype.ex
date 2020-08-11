defmodule Backend.HSReplay.Archetype do
  @moduledoc false
  use TypedStruct
  alias Backend.HSReplay.Archetype.CcpSignatureCore, as: Signature

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
    field :standard_cpp_signature_core, Signature.t()
    field :wild_cpp_signature_core, Signature.t()
  end

  def from_raw_map(map = %{"playerClass" => _}) do
    map
    |> Recase.Enumerable.convert_keys(&Recase.to_snake/1)
    |> from_raw_map()
  end

  def from_raw_map(
        m = %{
          "player_class" => pc,
          "player_class_name" => pcn,
          "url" => url,
          "name" => name,
          "id" => id
        }
      ) do
    %__MODULE__{
      id: id,
      name: name,
      player_class: pc,
      player_class_name: pcn,
      url: url,
      standard_cpp_signature_core: Signature.from_raw_map(m["standard_ccp_signature_core"]),
      wild_cpp_signature_core: Signature.from_raw_map(m["wild_ccp_signature_core"])
    }
  end

  def signature_core(%{wild_cpp_signature_core: core}, 1), do: core
  def signature_core(%{standard_cpp_signature_core: core}, 2), do: core
  def signature_core(_, _), do: nil

  defp compare_as_of(a = %__MODULE__{}, b = %__MODULE__{}, format) do
    a_core = a |> signature_core(format)
    b_core = b |> signature_core(format)
    NaiveDateTime.compare(a_core, b_core)
  end
end

defmodule Backend.HSReplay.Archetype.CcpSignatureCore do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :as_of, NaiveDateTime.t()
    field :format, integer
    field :components, [integer]
  end

  def from_raw_map(m = %{"as_of" => as_of_raw}) do
    %__MODULE__{
      as_of: NaiveDateTime.from_iso8601!(as_of_raw),
      format: m["format"],
      components: m["components"]
    }
  end

  def from_raw_map(nil), do: nil
end
