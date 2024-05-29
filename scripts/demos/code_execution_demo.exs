IO.puts("Starting code execution demo...")

code_executor_agent = %XAgent{
  name: "code_executor_agent",
  type: :conversable_agent,
  is_code_executor: true,
  human_input_mode: :always,
  is_termination_msg: fn msg -> String.contains?(msg.content, "TERMINATE") end
}

code_writer_agent = %XAgent{
  name: "code_writer_agent",
  system_prompt: ~S"""
  You are a helpful AI assistant.
  Solve tasks using your coding and language skills.
  In the following cases, suggest Elixir code (in a elixir coding block) for the user to execute.
  The last expression in your code should compute and return the result (rather than print it).
  Check the execution result returned by the user.
  If the result indicates there is an error, fix the error and output the code again. Suggest the full code instead of partial code or code changes. If the error can't be fixed or if the task is not solved even after the code is executed successfully, analyze the problem, revisit your assumption, collect additional info you need, and think of a different approach to try.
  When you find an answer, verify the answer carefully. Include verifiable evidence in your response if possible.
  If the execution was successful and everything is done, reply with 'TERMINATE'.
  """,
  type: :conversable_agent
}

XAgent.initiate_chat(
  from_agent: code_executor_agent,
  to_agent: code_writer_agent,
  message: "Write Elixir code to calculate the 14th Fibonacci number."
)
