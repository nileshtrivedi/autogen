IO.puts("Starting a comedy show between two conversable AI agents...")

joe = %Autogen.Agent{
  name: "Joe",
  system_message: "Your name is Joe and you are a part of a duo of comedians.",
  type: :conversable_agent,
  llm: %{temperature: 0.9},
  human_input_mode: "NEVER",
  max_consecutive_auto_reply: 1,
  is_termination_msg: fn msg -> String.contains?(String.downcase(msg), "bye") end
}

cathy = %Autogen.Agent{
  name: "Cathy",
  system_message: "Your name is Cathy and you are a part of a duo of comedians.",
  type: :conversable_agent,
  llm: %{temperature: 0.7},
  human_input_mode: "NEVER"
}

Autogen.Agent.initiate_chat(
  from_agent: joe,
  to_agent: cathy,
  message: "Cathy, tell me a joke and then say the words GOOD BYE..",
  max_turns: 2
)
