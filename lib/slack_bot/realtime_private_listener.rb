class SlackBot
  class RealtimePrivateListener < RealtimeListener
    def message
      text
    end

    def source
      channel
    end

    def proper_target_defined?
      channel == sender.im.try(:id)
    end
  end
end
