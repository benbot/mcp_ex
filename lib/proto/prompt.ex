defmodule McpEx.Proto.Prompt do
  use Ecto.Schema
  import Ecto.Changeset
  alias McpEx.Server.ConnectionState
  alias McpEx.Proto.GetPromptResponse
  alias McpEx.Proto.PromptArg
  require Logger

  schema "prompt" do
    field(:name, :string)
    field(:description, :string)
    field(:handler, :any, virtual: true)

    embeds_many(:arguments, PromptArg)
  end

  def changeset(%__MODULE__{} = prompt, attrs) do
    prompt
    |> cast(attrs, [:name, :description, :handler, :arguments, :required])
    |> cast_embed(:arguments)
    |> validate_required([:name, :description, :handler])
    |> validate_change(:handler, fn f, v ->
      case is_function(v) do
        true -> []
        false -> [{f, "handler must be a function"}]
      end
    end)
  end

  @spec get_prompts_list(atom()) :: list(%__MODULE__{})
  def get_prompts_list(module) do
    McpEx.Server.Info.prompts(module)
  end

  @spec get_prompt(%ConnectionState{}, atom(), String.t(), map()) :: any()
  def get_prompt(state, module, prompt_name, arguments) do
    prompt =
      McpEx.Server.Info.prompts(module)
      |> Enum.find(&(&1.name == prompt_name))

    case prompt do
      nil ->
        Logger.error("no prompt found for: #{prompt_name}. TODO: return proper error")
        %{}

      p ->
        resp =
          apply(p.handler, [state, arguments])

        result =
          GetPromptResponse.changeset(
            %GetPromptResponse{},
            resp |> Map.put(:description, p.description)
          )

        case result.valid? do
          true ->
            result |> Ecto.Changeset.apply_changes()

          false ->
            raise "Some kinda validation error on : #{result}"
        end
    end
  end
end
