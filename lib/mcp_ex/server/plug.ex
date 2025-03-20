defmodule McpEx.Server.Plug do
  require Logger

  alias McpEx.Proto.ListPromptResponse
  alias McpEx.Proto
  alias McpEx.Server.ConnectionState

  use Plug.Router

  require McpEx.Utils

  plug(:match)
  plug(:dispatch)

  def call(conn, opts) do
    conn
    |> put_private(:spark_mod, opts[:spark_mod])
    |> super(opts)
  end

  post "/sse" do
    conn =
      conn
      |> keep_alive_headers()
      |> send_chunked(200)

    id = UUID.uuid4()
    {:ok, _} = Registry.register(McpEx.SSERegistry, id, nil)

    {:ok, conn} = conn |> chunk("event: connected\n\n")
    {:ok, conn} = conn |> chunk("endpoint: http://localhost:4000/mcp?init_id=#{id}\n\n")

    loop(conn)
  end

  post "/mcp/:session_id" do
    {:ok, body, _} = conn |> read_body()

    case body do
      "" ->
        conn |> send_resp(400, "no body") |> halt()

      body ->
        message = Poison.decode!(body)

        unless message["jsonrpc"] == "2.0" do
          conn |> send_resp(400, "invalid jsonrpc payload") |> halt()
        end

        conn |> handle_message(message)
    end
  end

  # Handle requests
  defp handle_message(conn, %{"id" => msg_id, "method" => "initialize"} = body) do
    id = conn.path_params["session_id"]

    res = ConnectionState.initialize_state(conn.private.spark_mod, body["params"], id)
    {:ok, state, response} = res

    get_pid_from_id(id)
    |> send({:initialize, state, response, msg_id})

    conn |> send_resp(200, "OK")
  end

  # prompt methods
  defp handle_message(conn, %{"id" => msg_id, "method" => "prompts/list"}) do
    conn.path_params["session_id"]
    |> get_pid_from_id()
    |> send({:prompts_list, msg_id})

    conn |> send_resp(200, "OK")
  end

  defp handle_message(conn, %{"id" => msg_id, "method" => "prompts/get", "params" => params}) do
    conn.path_params["session_id"]
    |> get_pid_from_id()
    |> send({:prompts_get, params, msg_id})

    conn |> send_resp(200, "OK")
  end

  # resource methods

  defp handle_message(conn, %{"id" => msg_id, "method" => "resources/list"}) do
    conn.path_params["session_id"]
    |> get_pid_from_id()
    |> send({:resources_list, msg_id})

    conn |> send_resp(200, "OK")
  end

  # Handle Notifications
  defp handle_message(%{assigns: %{state: _state}} = _conn, %{"method" => _method} = _body) do
    raise "IMPL NOTIF"
  end

  defp handle_message(conn, msg) do
    Logger.error("Msg no good: #{msg}")
    conn |> send_resp(400, "Bad Request") |> halt()
  end

  defp loop(conn) do
    McpEx.Utils.unless_halted conn do
      receive do
        {:initialize, state, msg, msg_id} ->
          conn
          |> assign(:state, state)
          |> send_sse_message(Proto.Response.with_result(msg, msg_id))
          |> loop()

        {:prompts_list, msg_id} ->
          conn =
            conn |> ensure_initialized()

            prompts = Proto.Prompt.get_prompts_list(conn.private.spark_mod)

            resp =
              prompts
              |> Enum.map(fn p ->
                ListPromptResponse.changeset(%ListPromptResponse{}, Map.from_struct(p)) 
                |> Ecto.Changeset.apply_changes() 
                |> ListPromptResponse.to_result_map()
              end)
              |> then(&Proto.Response.with_result(%{prompts: &1}, msg_id))

            conn
            |> send_sse_message(resp)
            |> loop()

        {:prompts_get, params, msg_id} ->
          conn = 
            conn
            |> ensure_initialized()

          resp =
            Proto.Prompt.get_prompt(
              conn.assigns.state,
              conn.private.spark_mod,
              params["name"],
              params["arguments"]
            )
            |> Map.from_struct()
            |> Map.drop([:__meta__])
            |> Proto.Response.with_result(msg_id)
          
          conn
          |> send_sse_message(resp)
          |> loop()
        {:resources_list, msg_id} ->
          conn = conn |> ensure_initialized()

          resp = Proto.Resource.get_resources_list(conn.private.spark_mod)
          |> Enum.map(&(&1 |> Map.from_struct() |> Map.drop([:__meta__])))
          |> Proto.Response.with_result(msg_id)

          conn
          |> send_sse_message(resp)
          |> loop()

        {:sse_message, data} -> send_sse_message(conn, data) |> loop()
        {:update_connection_state, updated_state} -> 
          conn |> assign(:state, updated_state)

        :quit ->
          conn
        other ->
          Logger.warning("UNKNOWN EVENT: #{inspect(other)}")
          loop(conn)
      after
        60000 ->
          conn
          |> send_sse_message(Proto.Response.with_result(%{"method" => "ping"}, UUID.uuid4()))
          |> loop()
      end
    end
  end

  # Utils
  @spec send_sse_message(%Plug.Conn{}, any()) :: %Plug.Conn{}
  def send_sse_message(conn, msg) do
    {:ok, conn} =
      conn
      |> chunk("event: message\ndata: #{msg}\n\n")

    conn
  end

  defp ensure_initialized(conn) do
    case conn.assigns[:state] do
      nil ->
        {:ok, conn} = conn |> chunk("event: message\n data: please initialize session\n\n")
        conn |> halt()

      _ ->
        conn
    end
  end

  defp get_pid_from_id(id) do
    {pid, _} = Registry.lookup(McpEx.SSERegistry, id) |> List.first()
    pid
  end

  defp keep_alive_headers(conn) do
    conn
    |> put_resp_header("Connection", "Keep-Alive")
    |> put_resp_header("Keep-Alive", "timeout=10000")
  end
end
