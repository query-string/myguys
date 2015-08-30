class SlackBot
  class PrivateFilter < Filter
    def proper_target_defined?
      realtime_message.proper_for_private?
    end
  end
end
