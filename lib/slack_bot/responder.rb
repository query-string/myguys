class SlackBot
  # Calculates destination
  # Validates message
  # Returns users
  # @TODO: Split to separated classes accroding to their responsibility
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
      case flag
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

    private

    def method_missing(method)
      POWERBALL_KEYS.include?(method.to_sym) ? powerball(method.to_sym) : super
    end

    def powerball(attr)
      response = if message.present?
        users.mentioned_ids.any? ? [:users, users.with_references] : [:notice, powerball_notice_empty]
      else
        [:notice, powerball_notice_nousers]
      end
      Hash[POWERBALL_KEYS.zip(response)][attr]
    end

    def powerball_notice_empty
      "How can I serve you, my dear @#{sender.name}?"
    end

    def powerball_notice_nousers
      "Sorry @#{sender.name}, your request must contain at least one *@username*"
    end
  end
end
