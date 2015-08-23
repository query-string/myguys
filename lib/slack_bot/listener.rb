class SlackBot
  class Listener
    include SlackBot::Environment
    attr_reader :attributes, :realtime, :message, :bot_user, :text, :channel

    def initialize(attributes)
      @attributes   = attributes
      @realtime     = attributes.realtime
      @message      = attributes.message

      @bot_user     = attributes.realtime.bot
      @text         = attributes.message.data.text
      @channel      = attributes.message.data.channel

      listen if proper_target_selected?
    end

    private

    def listen
      case parser_response[:type]
        when :notice
          SlackPost.execute parser_response[:destination], parser_response[:body]
        when :users
          hg_users = parser_response[:body].select { |user| user[:type] == :hg }
          SlackPostPhoto.execute parser_response[:destination], hg_users.first[:user].last_image if hg_users.size > 0
        end
    end

  end
end
