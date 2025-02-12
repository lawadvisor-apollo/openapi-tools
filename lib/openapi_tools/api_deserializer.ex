defmodule OpenapiTools.ApiDeserializer do
  def to_struct(map_or_list, module)
  def to_struct(nil, _), do: nil

  def to_struct(list, module) when is_list(list) and is_atom(module) do
    Enum.map(list, &to_struct(&1, module))
  end

  def to_struct(map, module) when is_map(map) and is_atom(module) do
    model = struct(module)

    model
    |> Map.keys()
    |> List.delete(:__struct__)
    |> Enum.reduce(model, fn field, acc ->
      if Map.has_key?(map, Atom.to_string(field)) do
        Map.replace(acc, field, Map.get(map, Atom.to_string(field)))
      else
        acc
      end
    end)
    |> module.decode()
  end

  def to_struct(value, module) when is_atom(module) do
    module.decode(value)
  end
end
