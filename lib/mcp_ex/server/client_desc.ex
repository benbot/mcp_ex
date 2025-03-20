defmodule McpEx.Server.ClientDesc do
  import Ecto.Changeset

  defmodule ClientInfo do
    use Ecto.Schema
    @primary_key false

    embedded_schema do
      field(:name, :string)
      field(:version, :string)
    end

    def changeset(root, attrs) do
      root
      |> cast(attrs, [:name, :version])
      |> validate_required([:name])
    end
  end

  defmodule ClientCapabilities do
    use Ecto.Schema
    @primary_key false

    defmodule Roots do
      use Ecto.Schema
      @primary_key false

      embedded_schema do
        field(:list_changed, :boolean)
      end

      def changeset(roots, %{"listChanged" => list_changed}) do
        roots
        |> cast(%{list_changed: list_changed}, [:list_changed])
        |> validate_required([:list_changed])
      end
    end

    embedded_schema do
      field(:sampling, :map)
      embeds_one(:roots, Roots)
    end

    def changeset(capability, attrs) do
      capability
      |> cast(attrs, [:sampling])
      |> validate_required([:sampling])
      |> cast_embed(:roots, required: true)
    end
  end
end
