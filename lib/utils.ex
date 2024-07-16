defmodule Autogen.Utils do
  def get_confirmation(prompt \\ "Are you sure? (yes/no): ") do
    do_get_confirmation(prompt)
  end

  defp do_get_confirmation(prompt) do
    response = IO.gets(prompt) |> String.trim() |> String.downcase()

    cond do
      response == "yes" or response == "y" ->
        true

      response == "no" or response == "n" ->
        false

      true ->
        do_get_confirmation("Invalid input. Please enter 'yes' or 'no': ")
    end
  end
end
