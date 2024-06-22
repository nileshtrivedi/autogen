defmodule AutogenTest do
  use ExUnit.Case
  doctest Autogen

  test "gemini api call" do
    request = LLMRequest.build_gemini_request([%{role: "user", content: "tell me a joke"}])
    resp = LLMRequest.dispatch(request)
    assert String.contains?(resp, "Why don't scientists trust atoms?")
  end
end
