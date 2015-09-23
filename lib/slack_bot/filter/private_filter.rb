class SlackBot
  class PrivateFilter < Filter
    def message
      text
    end

    def source
      channel
    end

    def proper_target_defined?
      channel == sender.id
    end
  end
end
