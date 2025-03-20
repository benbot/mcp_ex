defmodule McpEx.Utils do
  defmacro unless_halted(conn, do: body) do
    quote do
      case unquote(conn).halted do
        false -> unquote(body)
        true -> unquote(conn)
      end
    end
  end
end
