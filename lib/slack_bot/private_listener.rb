class SlackBot
  class PrivateListener < Listener
    def parser_response
      SlackBot::MessageParser.new(text, channel, attributes).response
    end

    def proper_target_selected?
      message.proper_for_private?
    end
  end
end
