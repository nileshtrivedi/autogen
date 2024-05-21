# Class hierarchy from python autogen
# CoreAgent > LLMAgent > ConversableAgent > UserProxyAgent
# CoreAgent > LLMAgent > ConversableAgent > AssistantAgent

defmodule CoreAgent do
  defstruct name: "", description: ""

  def send(%CoreAgent{}, _message, _recipient, _request_reply) do
    # Send a message to another agent.
  end

  def receive(%CoreAgent{}, _message, _sender, _request_reply) do
    # Receive a message from another agent.
  end

  def generate_reply(%CoreAgent{}, _messages, _sender) do
    # Generate a reply based on the received messages.
  end

  def new(name, description) do
    %CoreAgent{name: name, description: description}
  end
end

defmodule LLMAgent do
  defstruct agent: %CoreAgent{}, llm_config: %{}

  def system_message(%LLMAgent{}) do
  end

  def update_system_message(%LLMAgent{}) do
  end

  def name(%LLMAgent{} = agent) do
    agent.agent.name
  end

  def new(name, description, llm_config) do
    %LLMAgent{agent: CoreAgent.new(name, description), llm_config: llm_config}
  end
end

defmodule ConversableAgent do
  defstruct llm_agent: %LLMAgent{}

  def name(%ConversableAgent{} = agent) do
    agent.llm_agent.name
  end

  def new(name, description, llm_config) do
    %ConversableAgent{llm_agent: LLMAgent.new(name, description, llm_config)}
  end
end

defmodule UserProxyAgent do
  defstruct conversable_agent: %ConversableAgent{}

  def new(name, description, llm_config) do
    %UserProxyAgent{conversable_agent: ConversableAgent.new(name, description, llm_config)}
  end
end

defmodule AssistantAgent do
  defstruct conversable_agent: %ConversableAgent{}

  def name(%AssistantAgent{} = agent) do
    agent.conversable_agent.name
  end

  def new(name, description, llm_config) do
    %AssistantAgent{conversable_agent: ConversableAgent.new(name, description, llm_config)}
  end
end

defmodule Autogen do
  def hello do
    :world
  end
end
