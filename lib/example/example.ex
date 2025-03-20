defmodule McpEx.Example do
  use McpEx.Server

  prompts do
    prompt "test1", "test" do
      handler(fn state, args ->
        %{
          messages: [
            %{role: "user", content: %{type: "text", text: "ello"}}
          ]
        }
      end)
    end
  end

  resources do
    resource "test"
  end

  tools do
  end
end
