defmodule McpEx.Proto do
  def validate_role(cs, field_name) do
    import Ecto.Changeset

    cs
    |> validate_change(field_name, fn ^field_name, val ->
      case val do
        "user" -> []
        "assistant" -> []
        _ -> [{field_name, 3}]
      end
    end)
  end
end

defmodule McpEx.Proto.Request do
  @derive [Poison.Decoder]

  defstruct [
    :id,
    :method,
    :params,
    :jsonrpc
  ]

  defmacro embed do
    quote do
      field(:id, :string)
      field(:method, :string)
    end
  end
end

defmodule McpEx.Proto.Response do
  @derive [Poison.Decoder]

  defstruct [
    :id,
    :jsonrpc,
    :result,
    :error
  ]

  @spec with_result(map() | list(), String.t()) :: String.t()
  def with_result(result, message_id) do
    Poison.encode!(%__MODULE__{
      jsonrpc: "2.0",
      id: message_id,
      result: result
    })
  end
end

defmodule McpEx.Proto.Notification do
  @derive [Poison.Decoder]

  defstruct [
    :jsonrpc,
    :method,
    :params
  ]
end

defmodule McpEx.Proto.TextContent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:type, :string, default: "text")
    field(:text, :string)
  end

  def changeset(%__MODULE__{} = response, attrs) do
    response
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end

  def from(map), do: Map.put(map, :__type__, :text)
end

defmodule McpEx.Proto.Annotation do
  use Ecto.Schema
  import Ecto.Changeset
  import McpEx.Proto

  @primary_key false
  embedded_schema do
    field(:audience, :string)
    field(:priority, :integer)
  end

  def changeset(%__MODULE__{} = annotation, attrs) do
    annotation
    |> cast(attrs, [:audience, :priority])
    |> validate_role(:priority)
  end
end
