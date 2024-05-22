defmodule XMessage do
  defstruct content_type: "", content_body: "", role: "", context: %{}, tools: []
end

defmodule XAgent do
  # https://microsoft.github.io/autogen/docs/tutorial/introduction
  # Agents are abstract entities that can send messages, receive messages
  # and generate a reply using models, tools, human inputs or a mixture of them.
  # An agent can be powered by LLMs or CodeExecutors, Humans or a combination of these.
  defstruct name: "", description: "", type: :conversable_agent, config: %{}

  def send_message(from_agent, to_agent, message, request_reply) do
    receive_message(from_agent, to_agent, message, request_reply)
  end

  def receive_message(from_agent, to_agent, message, _request_reply) do
    IO.puts "#{from_agent.name} to #{to_agent.name}: #{message.content_body}"
    send_message(to_agent, from_agent, generate_reply(to_agent, message), false)
  end

  def generate_reply(%XAgent{type: :conversable_agent} = agent, message) do
    {:ok, %{choices: [%{"message" => %{"content" => response}}]}} =
      OpenAI.chat_completion(%{
        model: "gpt-4o",
        messages: [
          %{role: "system", content: agent.description},
          %{role: "user", content: message.content_body}
        ]
      }, %{api_key: System.get_env("OPENAI_API_KEY")})
    response
  end

  def generate_reply(%XAgent{type: :user_proxy_agent} = _agent, _message) do
    user_msg = String.trim(IO.gets("Your response: "))
    %XMessage{content_body: user_msg}
  end
end

defmodule Autogen do
  def comedy_show do
    IO.puts "Starting a comedy show between two conversable agents"
    joe = %XAgent{name: "Joe", type: :conversable_agent, config: %{}}
    cathy = %XAgent{name: "Cathy", type: :conversable_agent, config: %{}}

    msg = %XMessage{content_type: "text", content_body: "Cathy, tell me a joke.", role: "sender", context: %{}, tools: []}

    XAgent.send_message(joe, cathy, msg, false)
  end

  def assistant_demo do
    IO.puts "Starting assistant demo with the user"
    assistant = %XAgent{name: "Assistant", description: "You are a helpful chatbot", type: :conversable_agent, config: %{llm: %{}}}
    user = %XAgent{name: "user", type: :user_proxy_agent, config: %{code_execution_config: false}}

    msg = %XMessage{content_type: "text", content_body: "How can I help you today?", role: "sender", context: %{}, tools: []}
    XAgent.send_message(assistant, user, msg, false)
  end
end
