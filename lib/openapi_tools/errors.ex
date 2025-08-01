defmodule OpenapiTools.ErrorBuilder do
  @moduledoc """
  Builds OpenAPI error schemas with consistent structure.
  """

  alias OpenApiSpex.Schema

  @doc """
  Wraps an error schema in a standard error object format.
  """
  def error(error_schema) do
    %Schema{
      type: :object,
      properties: %{
        errors: error_schema
      }
    }
  end
end

defmodule OpenapiTools.Errors do
  @moduledoc """
  Standard HTTP error responses for OpenAPI specifications.

  Provides pre-defined error schemas and response builders for common HTTP status codes.
  """

  import OpenapiTools.SchemaBuilder
  import OpenapiTools.ErrorBuilder
  require OpenApiSpex
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  defmodule ErrorDetail do
    OpenApiSpex.schema(%{type: :object, properties: %{detail: schema(:string)}})
  end

  defmodule UnauthorizedError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  @doc """
  Returns a 401 Unauthorized response specification.
  """
  def unauthorized do
    Operation.response("Unauthorized", "application/json", UnauthorizedError)
  end

  defmodule ForbiddenError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  @doc """
  Returns a 403 Forbidden response specification.
  """
  def forbidden do
    Operation.response("Forbidden", "application/json", ForbiddenError)
  end

  defmodule NotFoundError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  @doc """
  Returns a 404 Not Found response specification.
  """
  def not_found do
    Operation.response("Not Found", "application/json", NotFoundError)
  end

  defmodule BadRequestError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  @doc """
  Returns a 400 Bad Request response specification.
  """
  def bad_request do
    Operation.response("Bad Request", "application/json", BadRequestError)
  end

  defmodule UnprocessableEntityError do
    OpenApiSpex.schema(error(%Schema{type: :object}))
  end

  @doc """
  Returns a 422 Unprocessable Entity response specification.
  """
  def unprocessable_entity do
    Operation.response("Unprocessable Entity", "application/json", UnprocessableEntityError)
  end

  defmodule InternalServerError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  @doc """
  Returns a 500 Internal Server Error response specification.
  """
  def internal_server_error do
    Operation.response("Internal Server Error", "application/json", InternalServerError)
  end

  @doc """
  Returns a list of common error responses (401, 403, 500).
  """
  def base_errors do
    [{401, unauthorized()}, {403, forbidden()}, {500, internal_server_error()}]
  end

  @doc """
  Merges base error responses with a given list of responses.
  """
  def with_base_errors(list) when is_list(list) do
    base_errors() ++ list
  end
end
