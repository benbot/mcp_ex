defmodule McpEx.Server.Transform do
  use Spark.Dsl.Transformer

  alias McpEx.Server

  def transform(map) do
    become_plug =
      quote do
        import Plug.Conn
        alias McpEx.Server

        def init(opts), do: [spark_mod: __MODULE__]
        def call(conn, opts), do: Server.SSEPlug.call(conn, Server.SSEPlug.init(opts))
      end

    sse? = Spark.Dsl.Transformer.get_option(map, [:transports], :sse?)

    case sse? do
      nil -> {:ok, Spark.Dsl.Transformer.eval(map, [], become_plug)}
      true -> {:ok, Spark.Dsl.Transformer.eval(map, [], become_plug)}
      _ -> {:ok, map}
    end
  end
end
