defmodule AutogenTest do
  use ExUnit.Case
  doctest Autogen

  test "comedy_show" do
    Autogen.comedy_show()
  end

  # test "assistant_demo" do
  #   Autogen.assistant_demo()
  # end
end
