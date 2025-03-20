defmodule McpEx.Server.Plug.Prompts do
  alias McpEx.Proto
  alias McpEx.Server

  @spec prompts_list(%Plug.Conn{}, String.t()) :: %Plug.Conn{}
  def prompts_list(conn, msg_id) do
    case conn.halted do
      false ->
        prompts = Proto.Prompt.get_prompts_list(conn.private.spark_mod)

        resp =
          prompts
          |> Enum.map(fn p ->
            %{
              name: p.name,
              description: p.description,
              arguments: p.arguments
            }
          end)
          |> then(&Proto.Response.with_result(%{prompts: &1}, msg_id))

        conn
        |> Server.Plug.send_sse_message(resp)

      true ->
        conn
    end
  end

  @spec prompt_get(%Plug.Conn{}, map(), String.t()) :: %Plug.Conn{}
  def prompt_get(conn, params, msg_id) do
    case conn.halted do
      false ->
        resp =
          Proto.Prompt.get_prompt(
            conn.assigns.state,
            conn.private.spark_mod,
            params["name"],
            params["arguments"]
          )
          |> Map.from_struct()
          |> Map.drop([:__meta__])

        conn |> Server.Plug.send_sse_message(Proto.Response.with_result(resp, msg_id))

      true ->
        conn
    end
  end
end
