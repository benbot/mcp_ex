defmodule McpEx.Server.Dsl do
  alias McpEx.Proto

  @prompt_argument %Spark.Dsl.Entity{
    name: :argument,
    describe: "An argument for the prompt",
    args: [:name, :description],
    target: Proto.PromptArg,
    schema: [
      name: [
        type: :string,
        required: true
      ],
      description: [
        type: :string,
        required: true
      ],
      required: [
        type: :boolean,
        default: false
      ]
    ],
    deprecations: []
  }
  @prompt %Spark.Dsl.Entity{
    name: :prompt,
    describe: "A Prompt per the MCP spec",
    args: [:name, :description],
    target: Proto.Prompt,
    entities: [arguments: [@prompt_argument]],
    schema: [
      name: [
        type: :string,
        required: true
      ],
      description: [
        type: :string,
        required: true
      ],
      handler: [
        type: {:fun, 2},
        required: true,
        doc: "Handler for prompts/get requests"
      ]
    ]
  }
  @prompts %Spark.Dsl.Section{
    name: :prompts,
    schema: [
      list_changed?: [
        type: :boolean,
        default: false,
        doc: "Should emit notifications when prompts change"
      ]
    ],
    entities: [
      @prompt
    ],
    describe: "The prompts per the MCP spec"
  }

  @resource %Spark.Dsl.Entity{
    name: :resource,
    args: [:name],
    target: McpEx.Proto.Resource,
    schema: [
      name: [
        type: :string,
        required: true
      ]
    ]
  }
  @resource %Spark.Dsl.Section{
    name: :resources,
    entities: [@resource],
    schema: [
      list_changed?: [
        type: :boolean,
        default: false,
        doc: "list changes"
      ]
    ]
  }

  defmodule Tool do
    defstruct [:name]
  end

  @tool %Spark.Dsl.Entity{
    name: :tool,
    args: [:name],
    target: Tool,
    schema: [
      name: [
        type: :string,
        required: true
      ]
    ]
  }

  @tools %Spark.Dsl.Section{
    name: :tools,
    entities: [@tool],
    schema: [
      list_changed?: [
        type: :boolean,
        default: false,
        doc: "list changes"
      ]
    ]
  }

  @transports %Spark.Dsl.Section{
    name: :transports,
    schema: [
      sse?: [
        type: :boolean,
        default: false,
        doc: "enable the sse transport"
      ]
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@prompts, @resource, @tools, @transports],
    transformers: [McpEx.Server.Transform]
end
