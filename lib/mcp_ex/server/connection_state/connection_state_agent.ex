defmodule McpEx.Server.ConnectionState.Agent do
  alias McpEx.Server.ConnectionState
  use Agent

  def start_link(val, id) do
    Agent.start_link(fn -> val end, name: {:via, Registry, {McpEx.SSERegistry, id}})
  end

  def initialize_state(module, params, id) do
    {:ok, state, response} = ConnectionState.inititalize_state(
      module,
      params,
      id
    )

    pid = start_link(state, id)

    {:ok, pid, response}
  end
end
