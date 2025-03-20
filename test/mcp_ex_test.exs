defmodule McpExTest do
  use ExUnit.Case
  doctest McpEx

  test "greets the world" do
    assert McpEx.hello() == :world
  end
end
