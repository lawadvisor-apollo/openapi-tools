defmodule Mix.Tasks.OpenapiTools.Gen.Client do
  @moduledoc """
  Mix task for generating OpenAPI clients.

  ## Usage

      mix openapi_tools.gen.client <output_path>
  """

  use Mix.Task

  alias OpenapiTools.ClientGeneration

  @doc """
  Runs the client generation task with the specified output path.
  """
  def run(args) do
    [path | _rest] = args
    config = ClientGeneration.config()

    ClientGeneration.generate_client(config, path)
  end
end
