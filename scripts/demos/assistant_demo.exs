IO.puts("Starting assistant demo with the user on command-line...")

assistant = %Autogen.Agent{
  name: "Assistant",
  system_message: "You are a helpful chatbot",
  type: :assistant_agent
}

user = %Autogen.Agent{
  name: "user",
  type: :user_proxy_agent
}

Autogen.Agent.initiate_chat(
  from_agent: assistant,
  to_agent: user,
  message: "How can I help you today?"
)
