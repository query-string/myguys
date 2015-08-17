class SlackBot
  # sender_user    - a real (most likely) person, WHO sends the message
  # recipient_user - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
  # bot_user       - an application user (application bot)
  class PublicListener < Listener
    attr_reader :response, :target_channel

    def initialize(attributes)
      @response       = attributes.response
      @target_channel = attributes.target_channel

      super
    end

    def splitted_text
      text.split(":")
    end

    def message
      splitted_text[1]
    end

    def recipient_user
      splitted_text[0]
    end

    def recipient_user_id
      recipient_user.match(regex).captures.join
    end

    def target_channel_id
      response.channels.find { |channel| channel.name == target_channel }.id
    end

    private

    def proper_target_selected?
      # If channel is target channel
      # If first part of messge – is username
      # If requested user id is equal to bot user id
      channel == target_channel_id && recipient_user =~ regex && recipient_user_id == bot_user.id
    end

    def parser_response
      SlackBot::MessageParser.new(message, "##{target_channel}", attributes).response
    end
  end
end
