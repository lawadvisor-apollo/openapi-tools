defmodule OpenapiTools.ClientGeneration do
  defmodule Config do
    defstruct [
      :spec,
      :package_name,
      :invoker_package,
      generator_image: "openapitools/openapi-generator-cli:v7.12.0"
    ]

    def new!(opts) do
      struct!(__MODULE__, opts)
    end
  end

  def config do
    opts = Application.get_env(:openapi_tools, __MODULE__)

    Config.new!(opts)
  end

  def generate_client(config, path) do
    {dir_result, 0} = System.shell("mktemp -d")

    dir = String.trim(dir_result)

    {file_result, 0} = System.shell("mktemp -p #{dir}")

    file = String.trim(file_result)

    {:ok, json} =
      OpenApiSpex.OpenApi.json_encoder().encode(config.spec.spec())

    json = json <> "\n"

    File.write!(file, json)

    assigns = [
      generator_image: config.generator_image,
      file: file,
      package_name: config.package_name,
      invoker_package: config.invoker_package
    ]

    cmd = """
    cat << EOF | docker build --progress plain --output=openapi -f - #{dir}
    #{dockerfile_template(assigns)}
    EOF
    """

    {_stdout, 0} = System.shell(cmd, cd: dir)

    Mix.Generator.create_directory(path)
    File.cp_r!(Path.join(dir, "openapi"), path)
    File.rm_rf!(dir)

    :ok
  end

  defp dockerfile_template(assigns) do
    """
    FROM <%= @generator_image %> AS build

    WORKDIR /openapi
    COPY <%= Path.basename(@file) %> .

    RUN /usr/local/bin/docker-entrypoint.sh generate \
      -i /openapi/<%= Path.basename(@file) %> \
      -g elixir \
      -o /openapi/client \
      --skip-validate-spec \
      --package-name <%= @package_name %> \
      --invoker-package <%= inspect @invoker_package %>

    FROM scratch
    COPY --from=build /openapi/client /
    """
    |> EEx.eval_string(assigns: assigns)
    |> String.trim()
  end
end
