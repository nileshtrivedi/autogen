defmodule AutogenTest do
  use ExUnit.Case
  doctest Autogen

  test "compiles" do
    assert Autogen.hello() == :world
  end
end
