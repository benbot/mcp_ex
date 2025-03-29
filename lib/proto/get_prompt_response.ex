defmodule McpEx.Proto.GetPromptResponse do
  alias McpEx.Proto.PromptMessage
  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  embedded_schema do
    field(:description, :string)

    embeds_many(:messages, PromptMessage)
  end

  def changeset(%__MODULE__{} = response, attrs) do
    response
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> cast_embed(:messages, required: true)
  end
end

defmodule McpEx.Proto.PromptMessage do
  alias McpEx.Proto.TextContent
  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  embedded_schema do
    field(:role, :string)

    polymorphic_embeds_one(:content,
      types: [
        text: TextContent
      ],
      on_type_not_found: :raise,
      on_replace: :update
    )
  end

  def changeset(%__MODULE__{} = response, %{"content" => _content} = attrs),
    do: changeset(response, Map.put(attrs, :content, attrs["content"]))

  def changeset(%__MODULE__{} = response, %{content: content} = attrs) do
    content =
      case content.type do
        "text" -> Map.put(content, :__type__, :text)
      end

    response
    |> cast(%{attrs | content: content}, [:role])
    |> cast_polymorphic_embed(:content,
      required: true,
      types: [
        text: TextContent
      ]
    )
  end
end
