defmodule LLMRequest do
  defstruct model: "gpt-4o", messages: [], api_key: System.get_env("OPENAI_API_KEY"), temperature: 1.0

  def dispatch(request) do
    # IO.puts "calling openai with: #{request.api_key}"
    OpenAI.chat_completion(
      [model: request.model, messages: request.messages, temperature: request.temperature],
      %OpenAI.Config{api_key: request.api_key}
    )
  end

  def populate_prompt(template, params) do
    {result, _binding} = Code.eval_string(template, params)
    result
  end
end

defmodule XTool do
  defstruct name: "", description: "", jsonschema: ""
end

defmodule XMessage do
  defstruct content: "", sender: "", receiver: ""
end

defmodule XThread do
  defstruct max_turns: nil, chat_history: []
end

defmodule XAgent do
  # https://microsoft.github.io/autogen/docs/tutorial/introduction
  # Agents are abstract entities that can send messages, receive messages
  # and generate a reply using models, tools, human inputs or a mixture of them.
  # An agent can be powered by LLMs or CodeExecutors, Humans or a combination of these.
  defstruct name: "", system_prompt: "", type: :conversable_agent, llm: %{}

  def initiate_chat(opts \\ []) do
    # This wraps the message in XMessage and sends it as XThread
    # Reset the consecutive auto reply counter.
    # If `clear_history` is True, the chat history with the recipient agent will be cleared.
    validated_opts = Keyword.validate!(opts, [from_agent: nil, to_agent: nil, message: nil, max_turns: nil])
    from_agent = validated_opts[:from_agent]
    to_agent = validated_opts[:to_agent]
    message = validated_opts[:message]
    max_turns = validated_opts[:max_turns]

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
    IO.puts "#{from_agent.name} to #{to_agent.name}: #{message.content}"

    if thread.max_turns != nil and length(thread.chat_history) == 2 * thread.max_turns do
      IO.puts "\n\n\nMax turns reached. Terminating."
      IO.puts inspect(thread.chat_history, pretty: true, width: 0)
    else
      if to_agent.type == :conversable_agent do
        reply_str = generate_reply(to_agent, message)
        reply_msg = %XMessage{content: reply_str, sender: to_agent.name, receiver: from_agent.name}
        send_thread(to_agent, from_agent, %XThread{thread | chat_history: [reply_msg | thread.chat_history]})
      end
    end
  end

  def generate_reply(%XAgent{type: :conversable_agent} = agent, message) do
    {:ok, %{choices: [%{"message" => %{"content" => response}}]}} = LLMRequest.dispatch(
      %LLMRequest{
        messages: [
          %{role: "system", content: agent.system_prompt},
          %{role: "user", content: message.content}
        ],
        temperature: agent.llm.temperature
      }
    )
    response
  end

  def generate_reply(%XAgent{type: :user_proxy_agent} = _agent, _message) do
    user_msg = String.trim(IO.gets("Your response: "))
    %XMessage{content: user_msg}
  end

  def agent_with_updated_system_message(agent, system_message) do
    struct(agent, config: %{agent.config | system_message: system_message})
  end
end
