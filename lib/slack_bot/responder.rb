class SlackBot
  # Calculates destination
  # Returns users
  # Validates message
  class Responder
    # target          – public channel which listens by default (usually #general)
    # source          – source channel from where message comes ATM (public channel OR PM)
    # mentioned_users - an array of users mentioned in message

    attr_reader :handler, :realtime, :event, :target, :sender, :message, :source

    POWERBALL_KEYS = %i(flag message)

    def initialize(handler)
      @handler  = handler
      @realtime = handler.realtime
      @event    = handler.event
      @target   = handler.target
      @sender   = handler.sender
      @message  = handler.message
      @source   = handler.source
    end

    def respond
      post if handler.proper_target_defined?
    end

    def post
      case validator.flag
        when :notice
          SlackPost.execute destination, event
        when :users
          SlackPostPhoto.execute destination, users.in_local.first[:user].last_image if users.in_local.any?
        end
    end

    def destination
      SlackBot::ResponderDestination.new(message: message, source: source, target: target, sender: sender).respond
    end

    def users
      SlackBot::ResponderUsers.new(realtime: realtime, message: message)
    end

    def validator
      SlackBot::Validator.new(users: users, message: message)
    end
  end
end
