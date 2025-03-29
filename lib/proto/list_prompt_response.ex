defmodule McpEx.Proto.ListPromptResponse do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:description, :string)
    field(:name, :string)

    embeds_many :arguments, McpEx.Proto.PromptArg
  end

  def changeset(%__MODULE__{} = response, attrs) do
    response
    |> cast(attrs, [:description, :name])
    |> validate_required([:description, :name])
    |> cast_embed(:arguments)
  end

  def to_result_map(%__MODULE__{} = result) do
    result |> Map.from_struct() |> Map.drop([:__meta__])
  end
end
