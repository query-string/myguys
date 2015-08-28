class SlackBot
  class PrivateGate < Gate
    def gate_text
      text
    end

    def gate_channel
      channel
    end

    def proper_target_selected?
      realtime_message.proper_for_private?
    end
  end
end
