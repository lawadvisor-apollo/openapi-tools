defmodule OpenapiTools.ApiDeserializerTest do
  use ExUnit.Case, async: true

  defmodule TestStruct do
    defstruct [
      :value,
      :list,
      :map,
      :field_to_be_filled_by_decode,
      field_with_default_value: "default value"
    ]

    def decode(val) do
      Map.replace(val, :field_to_be_filled_by_decode, "some value")
    end
  end

  test "to_struct/2 returns decoded struct" do
    val = %{
      "value" => "other value",
      "list" => ["item_1", "item_2"],
      "map" => %{"nested" => "nested value"}
    }

    assert struct = OpenapiTools.ApiDeserializer.to_struct(val, TestStruct)
    assert val["value"] == struct.value
    assert val["list"] == struct.list
    assert val["map"] == struct.map
    assert struct.field_to_be_filled_by_decode == "some value"
    assert struct.field_with_default_value == "default value"
  end
end
