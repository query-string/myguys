class SlackBot
  # Calculates destination
  # Validates message
  # Returns users
  class Forwarder
    # target          – public channel which listens by default (usually #general)
    # source          – source channel from where message comes ATM (public channel OR PM)
    # sender_user     - a real (most likely) person, WHO sends the message
    # channel_users   - a list of channel users brought by rtm.start response
    # mentioned_users - an array of users mentioned in message
    include SlackBot::Environment
    attr_reader :attributes, :realtime, :realtime_message, :target, :text, :source

    def initialize(attributes)
      @attributes       = attributes

      @realtime         = attributes.fetch(:realtime)
      @realtime_message = attributes.fetch(:realtime_message)
      @text             = attributes.fetch(:text)
      @source           = attributes.fetch(:source)
    end

    def mark
    end

    def destination
      text.present? ? catch_destination : source
    end

    def message
    end

    def sender_user_id
      realtime_message.sender_user_im.id
    end

    private

    def catch_destination
      substr = text.match(/show me|show us/)
      if substr
        substr.to_s.match(/me/) ? sender_user_id : "##{target}"
      else
        source
      end
    end
  end
end
