# Autogen

This is a work-in-progress Elixir port for Microsoft's agent framework: [Autogen](https://microsoft.github.io/autogen/).

An important goal of this library is to stay as close as possible to Microsoft's Python-based implementation of Autogen (for eg: class names/field names etc). This will make it possible to support feature like [AutoBuild](https://microsoft.github.io/autogen/blog/2023/11/26/Agent-AutoBuild) where entire agent group/library can be saved to a JSON file and loaded later. There are many other tools in the Autogen ecosystem. For example, [AutoGen Studio](https://microsoft.github.io/autogen/blog/2023/12/01/AutoGenStudio) (a web app to configure and test agents), [AutoGen Bench](https://microsoft.github.io/autogen/blog/2024/01/25/AutoGenBench) (for agent evaluations).

This is highly experimental and not at all ready for use in production.
This makes use of [langchain](https://github.com/brainlid/langchain) to make calls to various LLMs in a generic way. [Ollama](https://ollama.com/)'s Llama3 is used as the default LLM.

The conceptual architecture of autogen is explained in [this blog post by Chi Wang](https://microsoft.github.io/autogen/blog/2024/05/24/Agent).

## Near-term Goals

- Make [GroupChat](https://microsoft.github.io/autogen/docs/tutorial/conversation-patterns#group-chat) and [AutoBuild](https://microsoft.github.io/autogen/blog/2023/11/26/Agent-AutoBuild/) fully working.
- Integrate [aichat](https://github.com/nileshtrivedi/aichat) for a multi-user + multi-agent chat experience on web
- Build demos in [LiveBook](https://livebook.dev/)
- Leverage [instructor_ex](https://github.com/thmsmlr/instructor_ex)

## Longer-term Goals

- Enable streaming responses
- Turn agents into Erlang processes
- Build a comprehensive [library](https://microsoft.github.io/autogen/docs/Examples) of prompts, tools and [agents](https://microsoft.github.io/autogen/docs/notebooks) to make common use-cases trivial
- Handle real-time multi-modal input (images, audio, video, files)
- Reach capability at par with OpenAI's GPT-4o demos

## Usage

### Conversation between a user (on command-line) and a simple LLM assistant:
```elixir
    assistant = %Autogen.Agent{name: "Assistant", system_message: "You are a helpful chatbot", type: :conversable_agent}
    user = %Autogen.Agent{name: "user", type: :user_proxy_agent}

    Autogen.Agent.initiate_chat(from_agent: assistant, to_agent: user, message: "How can I help you today?")
```

### A back-and-forth conversation between two AI comedians:
```elixir
    alias LangChain.ChatModels.ChatOllamaAI
    joe = %Autogen.Agent{
      name: "Joe",
      system_message: "Your name is Joe and you are a part of a duo of comedians.",
      type: :conversable_agent,
      llm: %{temperature: 0.9},
      human_input_mode: :never,
      max_consecutive_auto_reply: 1,
      is_termination_msg: fn msg -> String.contains?(String.downcase(msg.content), "bye") end,
      chain: ChatOllamaAI.new!(%{model: "llama3"})
    }

    cathy = %Autogen.Agent{
      name: "Cathy",
      system_message: "Your name is Cathy and you are a part of a duo of comedians.",
      type: :conversable_agent,
      llm: %{temperature: 0.7},
      human_input_mode: :never,
      chain: ChatOllamaAI.new!(%{model: "llama3"})
    }

    Autogen.Agent.initiate_chat(
      from_agent: joe,
      to_agent: cathy,
      message: "Cathy, tell me a joke and then say the words GOOD BYE..", max_turns: 2
    )
```

### Code writer agent and Code executor agents collaborating to perform a task:

```elixir
    code_executor_agent = %Autogen.Agent{
      name: "code_executor_agent",
      type: :conversable_agent,
      is_code_executor: true,
      human_input_mode: :always,
      is_termination_msg: fn msg -> String.contains?(msg.content, "TERMINATE") end,
      chain: ChatOllamaAI.new!(%{model: "llama3"})
    }

    code_writer_agent = %Autogen.Agent{
      name: "code_writer_agent",
      system_message: ~S"""
      You are a helpful AI assistant.
      Solve tasks using your coding and language skills.
      In the following cases, suggest Elixir code (in a elixir coding block) for the user to execute.
      The last expression in your code should compute and return the result (rather than print it).
      Check the execution result returned by the user.
      If the result indicates there is an error, fix the error and output the code again. Suggest the full code instead of partial code or code changes. If the error can't be fixed or if the task is not solved even after the code is executed successfully, analyze the problem, revisit your assumption, collect additional info you need, and think of a different approach to try.
      When you find an answer, verify the answer carefully. Include verifiable evidence in your response if possible.
      If the execution was successful and everything is done, reply with 'TERMINATE'.
      """,
      type: :conversable_agent,
      chain: ChatOllamaAI.new!(%{model: "llama3"})
    }

    Autogen.Agent.initiate_chat(
      from_agent: code_executor_agent,
      to_agent: code_writer_agent,
      message: "Write Elixir code to calculate the 14th Fibonacci number."
    )
```


## Installation

The package can be installed by adding it to your list of dependencies in `mix.exs`:

```
def deps do
  [{:autogen, "~> 0.3.0"}]
end
```

If you have cloned this repo, you can try the demos by making sure that llama3 is available on your machine and then running the following:

```bash
mix run scripts/demos/basic.exs
mix run scripts/demos/code_execution_demo.exs
mix run scripts/demos/assistant_demo.exs
mix run scripts/demos/comedy_show_demo.exs
```

For a simple chat UI using [PhoenixPlayground](https://github.com/phoenix-playground/phoenix_playground) and [DeepChat](https://deepchat.dev/):
```bash
iex scripts/demos/web_chat_ui.exs
```
