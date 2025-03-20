defmodule McpEx.Proto.ListResourceResult do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "prompts_list_result" do
    field :resources, :list
  end

  def changeset(%__MODULE__{} = response, attrs) do
    response
    |> cast(attrs, [:resources])
  end

  def to_result_map(%__MODULE__{} = result) do
    result |> Map.from_struct() |> Map.drop([:__meta__])
  end
end

defmodule McpEx.Proto.TextResourceContents do
  use Ecto.Schema
  import Echo.Changeset


  @primary_key false
  embedded_schema do
    field :uri, :string
    field :mime_type, :string
    field :text, :string
  end

  def changeset(%__MODULE__{} = response, attrs) do
    response
    |> cast(attrs, [:uri, :mime_type, :text])
    |> validate_required([:uri])
  end
end

defmodule McpEx.Proto.BlobResourceContents do
  use Ecto.Schema
  import Echo.Changeset


  @primary_key false
  embedded_schema do
    field :uri, :string
    field :mime_type, :string
    field :blob, :string
  end

  def changeset(%__MODULE__{} = response, attrs) do
    response
    |> cast(attrs, [:uri, :mime_type, :blob])
    |> validate_required([:uri])
  end
end
