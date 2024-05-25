IO.puts("Starting assistant demo with the user on command-line...")

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
