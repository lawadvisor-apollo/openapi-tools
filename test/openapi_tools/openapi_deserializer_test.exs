defmodule OpenapiTools.OpenapiDeserializerTest do
  use ExUnit.Case, async: true

  defmodule NestedStruct do
    defstruct [:key1, :key2, :key3]
  end

  defmodule TestStruct do
    defstruct [
      :value,
      :list,
      :map,
      field_with_default_value: "default value"
    ]

    def from_openapi(struct, value) do
      %{
        struct
        | value: value.value,
          list: value.list,
          map:
            OpenapiTools.OpenapiDeserializer.to_struct(value.map, NestedStruct,
              with: fn nested_struct, nested_value ->
                %{
                  nested_struct
                  | key1: nested_value.key1,
                    key2: nested_value.key2,
                    key3: nested_value.key3
                }
              end
            ),
          field_with_default_value: value.field_with_default_value
      }
    end
  end

  test "to_struct/2 returns decoded struct" do
    val = %{
      value: "other value",
      list: [1, 2, 3],
      map: %{key1: "a", key2: "b", key3: "c"},
      field_with_default_value: nil
    }

    assert struct = OpenapiTools.OpenapiDeserializer.to_struct(val, TestStruct)
    assert val.value == struct.value
    assert val.list == struct.list
    assert val.map == Map.from_struct(struct.map)
    assert val.field_with_default_value == struct.field_with_default_value

    assert is_struct(struct, TestStruct)
    assert is_struct(struct.map, NestedStruct)
    assert struct.field_with_default_value == nil
  end
end
