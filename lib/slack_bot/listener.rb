class SlackBot
  class Listener
    include SlackBot::Environment
    attr_reader :attributes, :data, :text, :channel, :bot_user

    def initialize(attributes)
      @attributes   = attributes
      @bot_user     = attributes.client.bot
      @data         = attributes.data
      @text         = attributes.data.text
      @channel      = attributes.data.channel

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
