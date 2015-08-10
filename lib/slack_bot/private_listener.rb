class SlackBot
  class PrivateListener
    attr_reader :attributes, :data, :sender_user, :im_list

    def initialize(attributes)
      @attributes = attributes
      @data        = attributes.data
      @sender_user = attributes.data.user
      @im_list     = attributes.im_list

      listen if data.channel == sender_user_im.id # If PM user is bot user
    end

    def bot_user
      attributes.bot_user
    end

    def sender_user_im
      @sender_user_im ||= im_list.find { |im| im.user == sender_user }
    end

    private

    def listen
      p "I'm listening..."
    end
  end
end
