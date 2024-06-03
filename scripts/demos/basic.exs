# IO.puts("Starting basic demo...")

# agent = %XAgent{
#   name: "chatbot",
#   type: :conversable_agent,
#   function_map: nil,
#   human_input_mode: "NEVER"
# }

# thread = %XThread{chat_history: [%XMessage{content: "Tell me a joke."}]}

# reply = XAgent.generate_reply(agent, thread)

# IO.puts(reply)

IO.puts("Starting assistant demo...")

assistant = Autogen.create_assistant_agent()

thread = %XThread{chat_history: [%XMessage{content: "what is the factorial of 7?"}]}

IO.puts XAgent.generate_reply(assistant, thread)
