class SlackBot
  class PrivateListener < Listener
    attr_reader :channel, :sender_user, :im_list

    def initialize(attributes)
      super
      # If PM user is bot user
      listen if channel == sender_user_im.try(:id)
    end

    def sender_user_im
      @sender_user_im ||= im_list.find { |im| im.user == sender_user }
    end

    private

    def parser_response
      SlackBot::MessageParser.new(message, channel, attributes).response
    end
  end
end
