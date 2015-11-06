class SlackBot
  # Calculates destination
  # Returns users
  # Validates message
  class Responder
    # target          – public channel which listens by default (usually #general)
    # source          – source channel from where message comes ATM (public channel OR PM)
    # mentioned_users - an array of users mentioned in message

    attr_reader :handler, :realtime, :event, :target, :sender, :message, :source

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
      validation.validate
      validation.successful? ? post_photo : post_notice
    end

    private

    def post_notice
      validation.muted_notices.each { |notice| SlackPost.execute sender.im, notice }
    end

    def post_photo
      SlackPostPhoto.execute destination, users.in_local.first[:user].last_image if users.in_local.any?
    end

    def users
      @_users ||= SlackBot::ResponderUsers.new(realtime: realtime, message: message)
    end

    def destination
      @_destination ||= SlackBot::ResponderDestination.new(message: message, source: source, target: target, sender: sender).respond
    end

    def validation
      @_validation ||= SlackBot::ResponderValidator.new(users: users, message: message, sender: sender)
    end
  end
end
