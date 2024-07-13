defmodule XAgent do
  # https://microsoft.github.io/autogen/docs/tutorial/introduction
  # Agents are abstract entities that can send messages, receive messages
  # and generate a reply using models, tools, human inputs or a mixture of them.
  # An agent can be powered by LLMs or CodeExecutors, Humans or a combination of these.
  defstruct name: "",
            # user_proxy_agent, code_executor_agent, assistant_agent
            type: :conversable_agent,
            system_message: "You are a helpful AI Assistant.",
            is_termination_msg: nil,
            max_consecutive_auto_reply: nil,
            # ALWAYS, NEVER, TERMINATE
            human_input_mode: "TERMINATE",
            function_map: nil,
            code_execution_config: false,
            # dict or False or None
            llm_config: %{temperature: 0.0},
            default_auto_reply: "",
            description: nil,
            chat_messages: nil,
            model: "gpt-4o"

  def initiate_chat(opts \\ []) do
    # This wraps the message in XMessage and sends it as XThread
    # Reset the consecutive auto reply counter.
    # If `clear_history` is True, the chat history with the recipient agent will be cleared.
    %{
      from_agent: from_agent,
      to_agent: to_agent,
      message: message,
      max_turns: max_turns
    } = Enum.into(opts, %{from_agent: nil, to_agent: nil, message: nil, max_turns: nil})

    thread = %XThread{
      max_turns: max_turns,
      chat_history: [
        %XMessage{
          content: message,
          sender: from_agent.name,
          receiver: to_agent.name
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

  def receive_thread(from_agent, to_agent, thread) do
    message = List.first(thread.chat_history)
    IO.puts("#{from_agent.name} (to #{to_agent.name}):")
    IO.puts(message.content)
    IO.puts("--------------------------------------------------------------------------------")

    if !(err = should_stop_replying?(thread, message, to_agent)) do
      reply_str = generate_reply(to_agent, thread)
      reply_msg = %XMessage{content: reply_str, sender: to_agent.name, receiver: from_agent.name}

      send_thread(to_agent, from_agent, %XThread{
        thread
        | chat_history: [reply_msg | thread.chat_history]
      })
    else
      IO.puts("\n\n#{err}")
    end
  end

  def should_stop_replying?(thread, message, to_agent) do
    # TODO: Handle max_consecutive_auto_reply
    cond do
      thread.max_turns != nil and length(thread.chat_history) == 2 * thread.max_turns ->
        "Max turns reached"

      to_agent.type == :conversable_agent and to_agent.is_termination_msg != nil and
          to_agent.is_termination_msg.(message) ->
        "is_termination_msg matched"

      true ->
        false
    end
  end

  def generate_reply(%XAgent{} = agent, thread)
      when (agent.type == :conversable_agent or agent.type == :assistant_agent) and
             agent.code_execution_config == false do
    # Assemble message history correctly for the LLM
    # Our thread is sorted in reverse chronological order.
    # And we need to ask the LLM to behave like us (role=assistant), and we will play other agents' role (role=user)

    # So we reverse thread.chat_history and assign roles accordingly.
    # if message.sender is our name, set role to assistant, else set role to user.

    messages =
      Enum.reverse(thread.chat_history)
      |> Enum.map(fn msg ->
        %{role: if(msg.sender == agent.name, do: "assistant", else: "user"), content: msg.content}
      end)

    llm_messages = [%{role: "system", content: agent.system_message} | messages]

    # IO.puts "Sending to LLM: #{inspect(llm_messages)}"

    {:ok, %{choices: [%{"message" => %{"content" => response}}]}} =
      LLMRequest.dispatch(%LLMRequest{
        messages: llm_messages,
        temperature: agent.llm_config.temperature,
        model: agent.model
      })

    response
  end

  def generate_reply(agent, thread)
      when (agent.type == :conversable_agent or agent.type == :assistant_agent) and
             is_map(agent.code_execution_config) do
    message = List.first(thread.chat_history)

    code =
      message.content
      |> String.split("```elixir")
      |> List.last()
      |> String.split("```")
      |> List.first()

    if agent.human_input_mode == :never or
         XUtils.get_confirmation("Are you sure you want to run this code?") do
      {result, _binding} = Code.eval_string(code)
      "Code execution result: " <> inspect(result)
    end
  end

  def generate_reply(agent, _thread) when agent.type == :user_proxy_agent do
    String.trim(IO.gets("Your response: "))
  end
end
