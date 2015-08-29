class SlackBot
  class PrivateGate < Gate
    def proper_target_selected?
      realtime_message.proper_for_private?
    end
  end
end
