defmodule McpEx.Proto.PromptArg do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:description, :string)
    field(:required, :boolean, default: false)
  end

  def changeset(%__MODULE__{} = prompt, attrs) do
    prompt
    |> cast(attrs, [:name, :description, :required])
    |> validate_required([:name, :description])
  end
end
