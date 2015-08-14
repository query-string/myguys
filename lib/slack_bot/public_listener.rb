class SlackBot
  # sender_user    - a real (most likely) person, WHO sends the message
  # recipient_user - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
  # bot_user       - an application user (application bot)
  class PublicListener < Listener
    attr_reader :response, :target_channel

    def initialize(attributes)
      super
      # If channel is target channel
      # If first part of messge – is username
      # If requested user id is equal to bot user id
      listen if channel == target_channel_id && recipient_user =~ regex && recipient_user_id == bot_user.id
    end

    def regex
      attributes.regex
    end

    def splitted_message
      message.split(":")
    end

    def text
      splitted_message[1]
    end

    def sender_user_id
      data.user
    end

    def recipient_user
      splitted_message[0]
    end

    def recipient_user_id
      recipient_user.match(regex).captures.join
    end

    def channel
      data.channel
    end

    def target_channel_id
      response.channels.find { |channel| channel.name == target_channel }.id
    end

    private

    def parser_response
      SlackBot::MessageParser.new(text, "##{target_channel}", attributes).response
    end
  end
end
