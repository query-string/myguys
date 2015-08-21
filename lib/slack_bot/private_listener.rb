class SlackBot
  class PrivateListener < Listener
    attr_reader :sender_user, :im_list

    def initialize(attributes)
      @sender_user = attributes.data.user
      @im_list     = attributes.client.ims

      super
    end

    def sender_user_im
      @sender_user_im ||= im_list.find { |im| im.user == sender_user }
    end

    private

    def parser_response
      SlackBot::MessageParser.new(text, channel, attributes).response
    end

    def proper_target_selected?
      # If PM user is bot user
      channel == sender_user_im.try(:id)
    end
  end
end
