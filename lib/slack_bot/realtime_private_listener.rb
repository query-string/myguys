class SlackBot
  class RealtimePrivateListener < RealtimeListener
    def proper_target_defined?
      source == sender_user_im.try(:id)
    end
  end
end
