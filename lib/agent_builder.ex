# See https://microsoft.github.io/autogen/blog/2023/11/26/Agent-AutoBuild/

defmodule AgentBuilder do
  defstruct builder_model: nil, agent_model: nil, agent_list: [], agent_configs: []

  def build_agents(builder_task, llm_config, enable_coding) do

  end

  def start_task(execute_task, agent_list, llm_config) do
    # agents have been constructed, now initiate a groupchat among them to execute the task
  end

  def save(agent_builder) do
    # serialize to a string or a file
  end

  def load(raw_str) do
    # parse the given string or read the file and deserialize
    %AgentBuilder{}
  end
end
