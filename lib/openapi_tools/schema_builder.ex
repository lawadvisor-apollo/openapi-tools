defmodule OpenapiTools.SchemaBuilder do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  @ts %{
    inserted_at: %Schema{
      type: :string,
      format: :"date-time",
      example: "2017-07-21T17:32:28Z"
    },
    updated_at: %Schema{
      type: :string,
      format: :"date-time",
      example: "2017-07-21T17:32:28Z"
    }
  }

  def timestamps, do: @ts

  def with_timestamps(map) do
    Map.merge(@ts, map)
  end

  @pagination %{
    limit: %Schema{type: :integer},
    page: %Schema{type: :integer}
  }

  def with_pagination(map) do
    Map.merge(@pagination, map)
  end

  defmodule PaginationInfo do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        page_number: %Schema{type: :integer},
        page_size: %Schema{type: :integer},
        total_pages: %Schema{type: :integer},
        total_entries: %Schema{type: :integer}
      }
    })
  end

  def paginated_schema(schema) do
    %Schema{
      type: :object,
      properties: %{
        entries: %Schema{type: :array, items: schema},
        page_number: %Schema{type: :integer},
        page_size: %Schema{type: :integer},
        total_pages: %Schema{type: :integer},
        total_entries: %Schema{type: :integer}
      }
    }
  end

  def paginated_schema2(schema, key) do
    %Schema{
      type: :object,
      properties: %{
        :"#{key}" => %Schema{type: :array, items: schema},
        :metadata => PaginationInfo
      }
    }
  end

  def schema(kind, opts) when is_list(opts) do
    kind
    |> schema()
    |> Map.merge(Map.new(opts))
  end

  def schema({:array, schema}) do
    %Schema{type: :array, items: schema}
  end

  def schema(:string) do
    %Schema{type: :string}
  end

  def schema(:uuid) do
    %Schema{type: :string, format: :uuid}
  end

  def schema(:date_time) do
    %Schema{type: :string, format: :"date-time"}
  end

  def schema(:map) do
    %Schema{type: :object}
  end

  def schema(:binary) do
    %Schema{type: :string, format: :binary}
  end

  def schema(:date) do
    %Schema{type: :string, format: :date}
  end

  def schema(:bool) do
    %Schema{type: :boolean}
  end

  def schema(:int) do
    %Schema{type: :integer}
  end

  def schema(:decimal) do
    %Schema{type: :decimal}
  end

  def schema(:float) do
    %Schema{type: :number, format: :float}
  end

  def schema(:number) do
    %Schema{type: :number}
  end

  def to_parameters(mod, parameter_in \\ :query) do
    props = mod.schema().properties || []

    Enum.map(props, fn {field, schema} -> {field, [in: parameter_in, schema: schema]} end)
  end

  def responses(list) when is_list(list) do
    list
    |> List.flatten()
    |> Map.new()
  end

  def mediatype(kind, schema) do
    {List.last(Module.split(schema)), to_mimetype(kind), schema}
  end

  defp to_mimetype(:multipart) do
    "multipart/form-data"
  end

  defp to_mimetype(:json) do
    "application/json"
  end
end
