defmodule OpenapiTools.ErrorBuilder do
  alias OpenApiSpex.Schema

  def error do
    %{
      type: :object,
      properties: %{
        errors: %Schema{
          type: :object,
          properties: %{
            details: %Schema{type: :string}
          }
        }
      }
    }
  end
end

defmodule OpenapiTools.Errors do
  import OpenapiTools.ErrorBuilder
  require OpenApiSpex
  alias OpenApiSpex.Operation

  defmodule UnauthorizedError do
    OpenApiSpex.schema(error())
  end

  def unauthorized do
    Operation.response("Unauthorized", "application/json", UnauthorizedError)
  end

  defmodule ForbiddenError do
    OpenApiSpex.schema(error())
  end

  def forbidden do
    Operation.response("Forbidden", "application/json", ForbiddenError)
  end

  defmodule NotFoundError do
    OpenApiSpex.schema(error())
  end

  def not_found do
    Operation.response("Not Found", "application/json", NotFoundError)
  end

  defmodule UnprocessableEntityError do
    OpenApiSpex.schema(error())
  end

  def unprocessable_entity do
    Operation.response("Unprocessable Entity", "application/json", UnprocessableEntityError)
  end

  defmodule InternalServerError do
    OpenApiSpex.schema(error())
  end

  def internal_server_error do
    Operation.response("Internal Server Error", "application/json", InternalServerError)
  end

  def base_errors do
    [{402, unauthorized()}, {403, forbidden()}, {500, internal_server_error()}]
  end

  def with_base_errors(list) when is_list(list) do
    base_errors() ++ list
  end
end
