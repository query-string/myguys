class SlackBot
  class Listener
    attr_reader :attributes, :data, :message

    def initialize(attributes)
      @attributes  = attributes
      @data        = attributes.data
      @message     = attributes.data.text

      @response       = attributes.response
      @target_channel = attributes.target_channel

      @channel     = attributes.data.channel
      @sender_user = attributes.data.user
      @im_list     = attributes.im_list
    end

    def bot_user
      attributes.bot_user
    end

    private

    def listen
      case parser_response[:type]
        when :message
          SlackPost.execute parser_response[:destination], parser_response[:body]
        when :users
          hg_users = parser_response[:body].select { |user| user[:type] == :hg }
          SlackPostPhoto.execute parser_response[:destination], hg_users.first[:user].last_image if hg_users.size > 0
        end
    end

  end
end
