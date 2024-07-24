Mix.install([
  {:phoenix_playground, "~> 0.1.4"},
  {:autogen, path: "."}
])

defmodule SimplePlugRouter do
  use Plug.Router

  plug Plug.Parsers,
      parsers: [:json],
      pass: ["application/json"],
      json_decoder: Jason
  plug :match
  plug :dispatch

  get "/" do
    page = """
    <script type="module" src="https://unpkg.com/deep-chat@2.0.0/dist/deepChat.bundle.js"></script>
    <deep-chat
           connect='{
             "url": "http://localhost:4000/message",
             "method": "POST"
           }'
    ></deep-chat>
    """
    send_resp(conn, 200, page)
  end

  post "/message" do
    IO.inspect(conn.body_params, label: "Incoming request body")
    user_message = case conn.body_params do
      %{"messages" => [%{"text" => text} | _]} -> text
      _ -> "No message provided"
    end
    assistant = Autogen.create_basic_assistant()

    # TODO: Preserve chat_history across calls
    thread = %Autogen.Thread{
      chat_history: [
        %LangChain.Message{
          content: user_message,
          name: "user",
          role: :user
        }
      ]
    }

    reply = Autogen.Agent.generate_reply(assistant, thread)

    conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{role: "assistant", text: reply}))
  end

  match _ do
    send_resp(conn, 404, "Oops! Not Found")
  end
end

PhoenixPlayground.start(plug: SimplePlugRouter)
