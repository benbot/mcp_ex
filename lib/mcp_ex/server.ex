defmodule McpEx.Server do
  use Spark.Dsl,
    default_extensions: [
      extensions: [McpEx.Server.Dsl]
    ]
end
