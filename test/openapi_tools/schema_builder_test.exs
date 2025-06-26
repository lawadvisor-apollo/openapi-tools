defmodule OpenapiTools.SchemaBuilderTest do
  use ExUnit.Case, async: true
  alias OpenApiSpex.Schema
  alias OpenapiTools.SchemaBuilder

  describe "basic schema types" do
    test "creates number schemas" do
      assert %Schema{type: :number} = SchemaBuilder.schema(:number)
      assert %Schema{type: :number, format: :float} = SchemaBuilder.schema(:float)
      assert %Schema{type: :decimal} = SchemaBuilder.schema(:decimal)
    end

    test "creates string schemas" do
      assert %Schema{type: :string} = SchemaBuilder.schema(:string)
      assert %Schema{type: :string, format: :uuid} = SchemaBuilder.schema(:uuid)
    end

    test "creates other basic types" do
      assert %Schema{type: :integer} = SchemaBuilder.schema(:int)
      assert %Schema{type: :boolean} = SchemaBuilder.schema(:bool)
      assert %Schema{type: :object} = SchemaBuilder.schema(:map)
    end
  end

  describe "schema options" do
    test "merges options into schema" do
      schema = SchemaBuilder.schema(:string, example: "test", minLength: 3)
      assert schema.example == "test"
      assert schema.minLength == 3
    end
  end

  describe "array schemas" do
    test "creates array with item schema" do
      item_schema = SchemaBuilder.schema(:string)
      array_schema = SchemaBuilder.schema({:array, item_schema})
      
      assert %Schema{type: :array, items: ^item_schema} = array_schema
    end
  end

  describe "helper functions" do
    test "with_timestamps adds timestamp fields" do
      result = SchemaBuilder.with_timestamps(%{name: SchemaBuilder.schema(:string)})
      
      assert Map.has_key?(result, :inserted_at)
      assert Map.has_key?(result, :updated_at)
      assert Map.has_key?(result, :name)
    end

    test "paginated_schema creates pagination structure" do
      schema = SchemaBuilder.paginated_schema(SchemaBuilder.schema(:string))
      
      assert %Schema{type: :object, properties: properties} = schema
      assert Map.has_key?(properties, :entries)
      assert Map.has_key?(properties, :total_entries)
    end
  end
end