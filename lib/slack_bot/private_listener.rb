class SlackBot
  class PrivateListener
    attr_reader :attributes, :data, :channel, :sender_user, :im_list, :message

    def initialize(attributes)
      @attributes  = attributes
      @data        = attributes.data
      @channel     = attributes.data.channel
      @sender_user = attributes.data.user
      @message     = attributes.data.text
      @im_list     = attributes.im_list

      listen if channel == sender_user_im.try(:id) # If PM user is bot user
    end

    def bot_user
      attributes.bot_user
    end

    def sender_user_im
      @sender_user_im ||= im_list.find { |im| im.user == sender_user }
    end

    private

    def listen
      response = SlackBot::MessageParser.new(message, channel, attributes).response
      case response[:type]
        when :message
          SlackPost.execute response[:destination], response[:body]
        when :users
          hg_users = response[:body].select { |user| user[:type] == :hg }
          SlackPostPhoto.execute response[:destination], hg_users.first[:user].last_image if hg_users.size > 0
        end
    end
  end
end
