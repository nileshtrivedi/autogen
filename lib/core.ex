defmodule LLMRequest do
  defstruct model: "gpt-4o", messages: [], api_key: System.get_env("OPENAI_API_KEY"), temperature: 0.0

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
