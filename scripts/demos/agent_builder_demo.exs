builder_task = "Find a paper on arxiv by programming, and analyze its application in some domain. For example, find a latest paper about gpt-4 on arxiv and find its potential applications in software."
execute_task = "Find a recent paper about gpt-4 on arxiv and find its potential applications in software."

agent_builder = %AgentBuilder{
  builder_model: nil,
  agent_model: nil,
  agent_list: [],
  agent_configs: []
}

%{agent_list: agents, agent_configs: configs} = AgentBuilder.build_agents(builder_task, nil, false)

AgentBuilder.start_task(execute_task, agents, nil)
