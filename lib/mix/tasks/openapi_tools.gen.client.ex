defmodule Mix.Tasks.OpenapiTools.Gen.Client do
  use Mix.Task

  alias OpenapiTools.ClientGeneration

  def run(args) do
    [path | _rest] = args
    config = ClientGeneration.config()

    ClientGeneration.generate_client(config, path)
  end
end
