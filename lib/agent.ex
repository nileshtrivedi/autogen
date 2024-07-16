defmodule Autogen.Agent do
  # https://microsoft.github.io/autogen/docs/tutorial/introduction
  # Agents are abstract entities that can send messages, receive messages
  # and generate a reply using models, tools, human inputs or a mixture of them.
  # An agent can be powered by LLMs or CodeExecutors, Humans or a combination of these.
  defstruct name: "",
    type: :conversable_agent, # user_proxy_agent, code_executor_agent, assistant_agent
    system_message: "You are a helpful AI Assistant.",
    is_termination_msg: nil,
    max_consecutive_auto_reply: nil,
    human_input_mode: "TERMINATE", # ALWAYS, NEVER, TERMINATE
    function_map: nil,
    code_execution_config: false,
    llm: nil,
    default_auto_reply: "",
    description: nil,
    chat_messages: nil,
    chain: %{llm: LangChain.ChatModels.ChatOllamaAI.new!(%{model: "llama3"})}


  def initiate_chat(opts \\ []) do
    # This wraps the message in AutoGen.Thread before sending it.
    # Reset the consecutive auto reply counter.
    # If `clear_history` is True, the chat history with the recipient agent will be cleared.
    %{
      from_agent: from_agent,
      to_agent: to_agent,
      message: message,
      max_turns: max_turns
    } = Enum.into(opts, %{from_agent: nil, to_agent: nil, message: nil, max_turns: nil})

    thread = %Autogen.Thread{
      max_turns: max_turns,
      chat_history: [
        %LangChain.Message{
          role: :assistant,
          content: message,
          name: from_agent.name
        }
      ]
    }

    send_thread(from_agent, to_agent, thread)

    # This will trigger a cascade of function calls. If chat is initiated from A to B:
    # A sends -> B receives -> B optionally sends -> A receives -> A optionally sends and so on.
    # One round trip is 4 calls: A Sends, B Receives, B Sends, A Receives.
  end

  def send_thread(from_agent, to_agent, thread) do
    # Send and Receive are separate so that agents can do their own logging and pre/post processing.
    receive_thread(from_agent, to_agent, thread)
  end

  def receive_thread(%Autogen.Agent{} = from_agent, %Autogen.Agent{} = to_agent, %Autogen.Thread{} = thread) do
    message = List.last(thread.chat_history)
    IO.puts("#{from_agent.name} (to #{to_agent.name}):")
    # IO.puts("received latest message: #{inspect(message)}")
    IO.puts(message.content)
    IO.puts("--------------------------------------------------------------------------------")

    if !(err = should_stop_replying?(thread, message, to_agent)) do
      reply_str = generate_reply(to_agent, thread)
      reply_msg = %LangChain.Message{
        content: reply_str,
        name: to_agent.name,
        role: :user
      }
      send_thread(to_agent, from_agent, %Autogen.Thread{
        thread
        | chat_history: (thread.chat_history ++ [reply_msg])
      })
    else
      IO.puts("\n\n#{err}")
    end
  end

  def should_stop_replying?(
      %Autogen.Thread{chat_history: chat_history} = thread,
      %LangChain.Message{content: content} = _message,
      %Autogen.Agent{} = to_agent
    ) do
    # TODO: Handle max_consecutive_auto_reply
    cond do
      thread.max_turns != nil and length(chat_history) == 2 * thread.max_turns ->
        "Max turns reached"

        to_agent.type == :conversable_agent and to_agent.is_termination_msg != nil and
            to_agent.is_termination_msg.(content) ->
          "is_termination_msg matched"

      true -> false
    end
  end

  def generate_reply(%Autogen.Agent{} = agent, %Autogen.Thread{} = thread)
    when (agent.type == :conversable_agent or agent.type == :assistant_agent) and
      agent.code_execution_config == false do

    # We need to assemble the message history correctly before calling LLM
    # We are going to ask the LLM to behave like us (role=assistant), and we will play other agents' role (role=user)
    # if message.sender is our name, set role to assistant, else set role to user.

    sys_msg = %LangChain.Message{role: :system, content: agent.system_message, name: "system"}
    messages = thread.chat_history
      |> Enum.map(fn msg -> %LangChain.Message{
          role: (if msg.name == agent.name, do: :assistant, else: :user),
          content: msg.content,
          name: msg.name
        } end)

    # IO.puts("Sending to LLM: #{inspect(messages)}")

    {:ok, _updated_chain, response} =
      agent.chain
      |> LangChain.Chains.LLMChain.new!()
      |> LangChain.Chains.LLMChain.add_messages([sys_msg] ++ messages)
      |> LangChain.Chains.LLMChain.run()
      # |> IO.inspect()
    response.content
  end

  def generate_reply(%Autogen.Agent{} = agent, %Autogen.Thread{} = thread)
    when (agent.type == :conversable_agent or agent.type == :assistant_agent) and is_map(agent.code_execution_config) do
    ### Code execution

    message = List.last(thread.chat_history)
    code = message.content
    |> String.split("```elixir")
    |> List.last()
    |> String.split("```")
    |> List.first()

    IO.puts("Code to execute: #{code}")

    if agent.human_input_mode == :never or Autogen.Utils.get_confirmation("Are you sure you want to run this code?") do
      {result, _binding} = Code.eval_string(code)
      "Code execution result: " <> inspect(result)
    end
  end

  def generate_reply(agent, _thread) when agent.type == :user_proxy_agent do
    String.trim(IO.gets("Your response: "))
  end

  # defp maybe_put(map, _key, nil), do: map
  # defp maybe_put(map, key, value), do: Map.put(map, key, value)
  # defp safe_get(nil, _key), do: nil
  # defp safe_get(map, key), do: Map.get(map, key)
end
