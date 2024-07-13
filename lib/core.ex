defmodule LLMRequest do
  defstruct model: "llama3",
            messages: [],
            api_key: System.get_env("OPENAI_API_KEY"),
            temperature: 0.0

  def dispatch(%LLMRequest{model: "gpt-4o"} = request) do
    IO.puts("calling openai with: #{request.api_key}")

    OpenAI.chat_completion(
      [model: request.model, messages: request.messages, temperature: request.temperature],
      %OpenAI.Config{api_key: request.api_key}
    )
  end

  def dispatch(%LLMRequest{model: "gemini-1.5-flash"} = request) do
    url = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent"
    api_key = request.api_key

    body = %{
      "contents" => format_gemini_messages(request.messages)
    }

    response =
      Req.post!(
        "#{url}?key=#{api_key}",
        json: body,
        headers: [{"Content-Type", "application/json"}]
      )

    if response.status == 200 do
      response.body
      |> Map.get("candidates")
      |> Enum.at(0)
      |> Map.get("content")
      |> Map.get("parts")
      |> Enum.at(0)
      |> Map.get("text")
    else
      raise "Error: #{response.status} #{response.body}"
    end
  end

  def dispatch(%LLMRequest{} = request) do
    client = Ollama.init()

    response =
      Ollama.chat(client,
        model: request.model,
        messages: request.messages
      )

    {:ok, result} = response
    {:ok, %{choices: [result]}}
  end

  def build_gemini_request(messages) do
    %LLMRequest{
      model: "gemini-1.5-flash",
      messages: messages,
      api_key: System.get_env("GEMINI_API_KEY")
    }
  end

  def format_gemini_messages(messages) do
    # https://ai.google.dev/api/rest/v1beta/Content
    Enum.map(messages, fn message ->
      %{
        role: if(message.role == "user", do: "user", else: "model"),
        parts: [%{text: message.content}]
      }
    end)
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
