# Autogen

This is a work-in-progress Elixir port for Microsoft's agent framework: [Autogen](https://microsoft.github.io/autogen/).
This is highly experimental and not at all ready for use in production.

## Usage

Conversation between a user (on command-line) and a simple LLM assistant:
```elixir
assistant = %XAgent{name: "Assistant", description: "You are a helpful chatbot", type: :conversable_agent, config: %{llm: %{}}}
user = %XAgent{name: "user", type: :user_proxy_agent, config: %{code_execution_config: false}}

msg = %XMessage{content_type: "text", content_body: "How can I help you today?", role: "sender", context: %{}, tools: []}
XAgent.send_message(assistant, user, msg, false)
```

A back-and-forth conversation between two AI comedians:
```elixir
joe = %XAgent{name: "Joe", type: :conversable_agent, config: %{}}
cathy = %XAgent{name: "Cathy", type: :conversable_agent, config: %{}}

msg = %XMessage{content_type: "text", content_body: "Cathy, tell me a joke.", role: "sender", context: %{}, tools: []}

XAgent.send_message(joe, cathy, msg, false)
```

## Installation

This library has not yet been published on Hex. You must copy `autogen.ex` file manually into your own codebase.
If you have cloned this repo, you can try it with `OPENAI_API_KEY=your_openai_key mix test` which will invoke the assustant demo.
