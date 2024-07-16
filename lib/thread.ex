defmodule Autogen.Thread do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:max_turns, :integer)
    field(:chat_history, :any, virtual: true)
  end

  # chat_history is a list of LangChain.Message: https://hexdocs.pm/langchain/LangChain.Message.html
  # Each message has name, role and content.
  # role can be :user | :assistant | :system | :tool.
  # Currently, LangChain.Message has no way to indicate the recipient agent's name
end
