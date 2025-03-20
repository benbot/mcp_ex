# McpEx

An application and DSL for running Model Content Protocol Servers.

Made to learn more about Spark, MCP, and Elixir Macros

WARNING: Very VERY EARLY SOFTWARE. Not what I would call "usable" yet.
NOT FEATURE COMPLETE.

please check the `example.ex` for example of how to use it and the hurl files for examples of the requests needed to make

Notable missing features. I'll get to these in no particular order:

- [ ] DSL Validation
- [ ] listChanged messages
- [ ] Pagination
- [ ] Proper error messages
- [ ] Completion API
- [ ] Logging API
- [ ] Cancellation API
- [ ] Progress API
- [ ] Full documentation
- [ ] proper timeout handling when running functions

Features that do exist:

- Spark based DSL for defining prompts, resources, and tools
- Builds down into a Plug, for use with Phoenix, Bandit, or any other plug-friendly tools
- Handless the protocol's SSE transport. The provided plug keeps an open connection and provides a kind of session id
- Some documentation


## Installation


```elixir
def deps do
  [
    {:mcp_ex, github: "benbot/mcp_ex" }
  ]
end
```

Documentation (when it exists) can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/mcp_ex>.

