class SlackBot
  class RealtimePrivateListener < RealtimeListener
    def listener_text
      text
    end

    def listener_source
      source
    end

    def proper_target_defined?
      source == sender_user_im.try(:id)
    end
  end
end
