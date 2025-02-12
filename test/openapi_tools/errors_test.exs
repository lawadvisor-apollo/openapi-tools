defmodule OpenapiTools.ErrorsTest do
  use ExUnit.Case, async: true

  test "with_base_errors/1 returns concatenated list " do
    list = [{100, %OpenApiSpex.Response{description: "some description"}}]

    assert new_list = OpenapiTools.Errors.with_base_errors(list)
    assert is_list(new_list)
    assert errors = Enum.map(new_list, fn {_k, v} -> v end)
    assert OpenapiTools.Errors.unauthorized() in errors
    assert OpenapiTools.Errors.forbidden() in errors
    assert OpenapiTools.Errors.internal_server_error() in errors
  end
end
