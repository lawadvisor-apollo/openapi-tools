defmodule OpenapiTools.OpenapiDeserializer do
  defp decode_default(module) do
    fn struct, value ->
      module.from_openapi(struct, value)
    end
  end

  def to_struct(map_or_list, module, opts \\ [])
  def to_struct(nil, _, _opts), do: nil

  def to_struct(list, module, opts) when is_list(list) and is_atom(module) and is_list(opts) do
    Enum.map(list, &to_struct(&1, module, opts))
  end

  def to_struct(map, module, opts) when is_map(map) and is_atom(module) and is_list(opts) do
    struct = struct(module)

    decode =
      case Keyword.get(opts, :with) do
        with when is_function(with) -> with
        _any -> decode_default(module)
      end

    decode.(struct, map)
  end

  def to_struct(val, module, opts) when is_atom(module) do
    struct = struct(module)

    decode =
      case Keyword.get(opts, :with) do
        with when is_function(with) -> with
        _any -> decode_default(module)
      end

    decode.(struct, val)
  end
end
