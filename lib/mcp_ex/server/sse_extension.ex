defmodule McpEx.Server.SseExtension do
  use Spark.Dsl.Extension,
    transformers: [McpEx.Server.Transform]
end
