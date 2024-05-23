defmodule XUtils do
  def get_confirmation(prompt \\ "Are you sure? (yes/no) ") do
    IO.write(prompt)
    response = IO.gets("") |> String.trim() |> String.downcase()
    case response do
      "yes" -> true
      "y" -> true
      "no" -> false
      "n" -> false
      _ ->
        IO.puts("Invalid input. Please enter 'yes' or 'no'.")
        get_confirmation(prompt)  # Recursively prompt again for valid input
    end
  end
end
