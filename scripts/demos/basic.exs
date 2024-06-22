IO.puts("Starting assistant demo...")

assistant = Autogen.create_basic_assistant()
thread = %XThread{chat_history: [%XMessage{content: "what is the factorial of 7?"}]}

IO.puts XAgent.generate_reply(assistant, thread)
