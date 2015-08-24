class SlackBot
  # sender_user    - a real (most likely) person, WHO sends the message
  # recipient_user - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
  # bot_user       - an application user (application bot)
  class PublicListener < Listener
    def parser
      SlackBot::MessageParser.new(message, "##{target}", attributes).response
    end

    def proper_target_selected?
      # If channel is a target channel
      # If first part of messge – is a username
      # If requested user id is equal to bot user id
      channel == target_channel_id && recipient_user =~ regex && recipient_user_id == bot_user.id
    end

    private

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
      realtime.find_channel(target).try(:id)
    end
  end
end
