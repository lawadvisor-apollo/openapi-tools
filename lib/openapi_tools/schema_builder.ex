defmodule OpenapiTools.SchemaBuilder do
  @moduledoc """
  Utility functions for building OpenAPI schemas and responses.

  Provides helpers for common schema patterns like timestamps, pagination,
  and type definitions.
  """

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

  @doc """
  Returns standard timestamp schema fields (inserted_at, updated_at).
  """
  def timestamps, do: @ts

  @doc """
  Merges timestamp fields with the given schema map.
  """
  def with_timestamps(map) do
    Map.merge(@ts, map)
  end

  @pagination %{
    limit: %Schema{type: :integer},
    page: %Schema{type: :integer}
  }

  @doc """
  Merges pagination fields (limit, page) with the given schema map.
  """
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

  @doc """
  Creates a paginated response schema with entries and pagination metadata.
  """
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

  @doc """
  Creates a paginated response schema with custom key name and metadata.
  """
  def paginated_schema2(schema, key) do
    %Schema{
      type: :object,
      properties: %{
        :"#{key}" => %Schema{type: :array, items: schema},
        :metadata => PaginationInfo
      }
    }
  end

  @doc """
  Creates a schema of the given type with additional options.
  """
  def schema(kind, opts) when is_list(opts) do
    kind
    |> schema()
    |> Map.merge(Map.new(opts))
  end

  @doc """
  Creates a schema for the given primitive type or array.

  Supports: :string, :uuid, :date_time, :map, :binary, :date, :bool, :int, :decimal, :float, :number, {:array, schema}
  """
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

  @doc """
  Converts a module's schema properties to OpenAPI parameter definitions.
  """
  def to_parameters(mod, parameter_in \\ :query) do
    props = mod.schema().properties || []

    Enum.map(props, fn {field, schema} -> {field, [in: parameter_in, schema: schema]} end)
  end

  @doc """
  Converts a list of responses to a map for OpenAPI specification.
  """
  def responses(list) when is_list(list) do
    list
    |> List.flatten()
    |> Map.new()
  end

  @doc """
  Creates a media type tuple for OpenAPI request/response bodies.
  """
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
