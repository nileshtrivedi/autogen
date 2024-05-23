defmodule Autogen do
  def comedy_show do
    IO.puts "Starting a comedy show between two conversable agents"

    joe = %XAgent{
      name: "Joe",
      system_prompt: "Your name is Joe and you are a part of a duo of comedians.",
      type: :conversable_agent,
      llm: %{temperature: 0.9}
    }

    cathy = %XAgent{
      name: "Cathy",
      system_prompt: "Your name is Cathy and you are a part of a duo of comedians.",
      type: :conversable_agent,
      llm: %{temperature: 0.7}
    }

    XAgent.initiate_chat(from_agent: joe, to_agent: cathy, message: "Cathy, tell me a joke.", max_turns: 2)
  end

  def assistant_demo do
    IO.puts "Starting assistant demo with the user"
    assistant = %XAgent{
      name: "Assistant",
      system_prompt: "You are a helpful chatbot",
      type: :conversable_agent
    }

    user = %XAgent{
      name: "user",
      type: :user_proxy_agent
    }

    XAgent.initiate_chat(from_agent: assistant, to_agent: user, message: "How can I help you today?")
  end
end
