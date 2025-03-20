defmodule McpEx.Server.Info do
  use Spark.InfoGenerator,
    extension: McpEx.Server.Dsl,
    sections: [:prompts, :resources, :tools],
    entities: [:argument]
end
