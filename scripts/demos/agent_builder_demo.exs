builder_task = "Find a paper on arxiv by programming, and analyze its application in some domain. For example, find a latest paper about gpt-4 on arxiv and find its potential applications in software."
execute_task = "Find a recent paper about gpt-4 on arxiv and find its potential applications in software."

agent_builder = %Autogen.AgentBuilder{
  builder_model: nil,
  agent_model: nil,
  agent_list: [],
  agent_configs: []
}

%{agent_list: agents, agent_configs: configs} = Autogen.AgentBuilder.build_agents(builder_task, nil, false)

Autogen.AgentBuilder.start_task(execute_task, agents, nil)
