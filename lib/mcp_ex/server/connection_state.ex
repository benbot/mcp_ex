defmodule McpEx.Server.ConnectionState do
  use Ecto.Schema
  import Ecto.Changeset
  alias McpEx.Server.ClientDesc.ClientInfo
  alias McpEx.Server.ClientDesc.ClientCapabilities

  embedded_schema do
    embeds_one(:client_capabilities, ClientCapabilities)
    embeds_one(:client_info, ClientInfo)
  end

  def changeset(state, attrs) do
    state
    |> cast(attrs, [])
    |> cast_embed(:client_capabilities, required: true)
    |> cast_embed(:client_info, required: true)
  end

  @spec initialize_state(atom(), map(), String.t()) ::
          {:ok, map(), map()} | {:error, atom(), any()}
  def initialize_state(
        module,
        %{
          "protocolVersion" => "2024-11-05",
          "capabilities" => capabilities,
          "clientInfo" => client_info
        },
        id
      ) do
    cs =
      changeset(%__MODULE__{}, %{
        client_capabilities: capabilities,
        client_info: client_info,
        id: id,
        spark_mod: module
      })

    response = %{
      protocolVersion: "2024-11-05",
      capabilities: %{
        logging: %{},
        prompts: %{
          "listChanged" => false
        },
        resources: %{
          "listChanged" => false,
          "subscribe" => false
        },
        tools: %{
          "listChanged" => false
        }
      },
      serverInfo: %{
        name: "CONFIG ME",
        version: "CONFIG ME TOO"
      }
    }

    {:ok, cs |> apply_changes(), response}
  end

  def initialize_state(_) do
    {:error, :bad_init, "Bad initialize message"}
  end
end
