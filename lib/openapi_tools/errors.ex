defmodule OpenapiTools.ErrorBuilder do
  alias OpenApiSpex.Schema

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

  def unauthorized do
    Operation.response("Unauthorized", "application/json", UnauthorizedError)
  end

  defmodule ForbiddenError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  def forbidden do
    Operation.response("Forbidden", "application/json", ForbiddenError)
  end

  defmodule NotFoundError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  def not_found do
    Operation.response("Not Found", "application/json", NotFoundError)
  end

  defmodule BadRequestError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  def bad_request do
    Operation.response("Bad Request", "application/json", BadRequestError)
  end

  defmodule UnprocessableEntityError do
    OpenApiSpex.schema(error(%Schema{type: :object}))
  end

  def unprocessable_entity do
    Operation.response("Unprocessable Entity", "application/json", UnprocessableEntityError)
  end

  defmodule InternalServerError do
    OpenApiSpex.schema(error(ErrorDetail))
  end

  def internal_server_error do
    Operation.response("Internal Server Error", "application/json", InternalServerError)
  end

  def base_errors do
    [{401, unauthorized()}, {403, forbidden()}, {500, internal_server_error()}]
  end

  def with_base_errors(list) when is_list(list) do
    base_errors() ++ list
  end
end
