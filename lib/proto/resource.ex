defmodule McpEx.Proto.Resource do
  alias McpEx.Proto.Annotation
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:uri, :string)
    field(:name, :string)

    field(:description, :string)
    field(:mime_type, :string)
    field(:size, :integer)

    embeds_one(:annotations, Annotation)
  end

  def changeset(%__MODULE__{} = resource, attrs) do
    resource
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @spec get_resources_list(atom()) :: list(%__MODULE__{})
  def get_resources_list(module) do
    resources = McpEx.Server.Info.resources(module)
    cast(%__MODULE__{}, 
  end

  @spec resources_read fs
end
