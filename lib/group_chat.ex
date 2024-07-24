defmodule Autogen.GroupChat do
  # @default_intro_message "Hello everyone. We have assembled a great team today to answer questions and solve tasks. In attendance are:"
  @select_speaker_message_template """
  You are in a role play game. The following roles are available:
  {roles}.
  Read the following conversation.
  Then select the next role from {agentlist} to play. Only return the role.
  """

  @select_speaker_prompt_template """
  Read the above conversation. Then select the next role from {agentlist} to play. Only return the role.
  """

  @select_speaker_auto_multiple_template """
  You provided more than one name in your text, please return just the name of the next speaker. To determine the speaker use these prioritised rules:
  1. If the context refers to themselves as a speaker e.g. "As the..." , choose that speaker's name
  2. If it refers to the "next" speaker name, choose that name
  3. Otherwise, choose the first provided speaker's name in the context
  The names are case-sensitive and should not be abbreviated or changed.
  Respond with ONLY the name of the speaker and DO NOT provide a reason.
  """

  @select_speaker_auto_none_template """
  You didn't choose a speaker. As a reminder, to determine the speaker use these prioritised rules:
  1. If the context refers to themselves as a speaker e.g. "As the..." , choose that speaker's name
  2. If it refers to the "next" speaker name, choose that name
  3. Otherwise, choose the first provided speaker's name in the context
  The names are case-sensitive and should not be abbreviated or changed.
  The only names that are accepted are {agentlist}.
  Respond with ONLY the name of the speaker and DO NOT provide a reason.
  """

  defstruct agents: [],
            messages: [],
            max_round: 10,
            admin_name: "Admin",
            func_call_filter: true,
            # AUTO, RANDOM, MANUAL, ROUND_ROBIN
            speaker_selection_method: "AUTO",
            max_retries_for_selecting_speaker: 2,
            allow_repeat_speaker: nil,
            allowed_or_disallowed_speaker_transitions: nil,
            speaker_transition_types: nil,
            enable_clear_history: false,
            send_introductions: false,
            select_speaker_message_template: @select_speaker_message_template,
            select_speaker_prompt_template: @select_speaker_prompt_template,
            select_speaker_auto_multiple_template: @select_speaker_auto_multiple_template,
            select_speaker_auto_none_template: @select_speaker_auto_none_template,
            select_speaker_auto_verbose: false,
            role_for_select_speaker_messages: "system"

  def next_agent() do
  end

  def random_select_speaker() do
  end
end
