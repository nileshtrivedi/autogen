IO.puts("Starting assistant demo...")

assistant = Autogen.create_basic_assistant()

thread = %Autogen.Thread{
  chat_history: [
    %Autogen.Message{
      content: "what is the factorial of 7?"
    }
  ]
}

IO.puts Autogen.Agent.generate_reply(assistant, thread)
