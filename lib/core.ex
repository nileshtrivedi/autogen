defmodule XTool do
  defstruct name: "", description: "", jsonschema: ""
end

defmodule XThread do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:max_turns, :integer)
    field(:chat_history, :any, virtual: true)
  end
end
