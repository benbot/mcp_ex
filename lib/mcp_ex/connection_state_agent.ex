defmodule McpEx.ConnectionStateAgent do
  use Agent

  def start_link(val, id) do
    Agent.start_link(fn -> val end, name: {:via, Registry, {McpEx.SSERegistry, id}})
  end
end
