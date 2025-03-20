defmodule McpEx.Application do
  use Application

  @impl true
  def start(_, _) do
    children = [
      {Registry, name: McpEx.SSERegistry, keys: :unique}
    ]

    opts = [strategy: :one_for_one, name: McpEx.ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end
end
