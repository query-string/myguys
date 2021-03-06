class SlackBot
  class Responder
    attr_reader :handler, :realtime, :event, :target, :seeker, :message, :source

    def initialize(handler)
      @handler  = handler
      @realtime = handler.realtime
      @event    = handler.event
      @target   = handler.target
      @seeker   = handler.seeker
      @message  = handler.message
      @source   = handler.source
    end

    def respond
      post if handler.proper_target_defined?
    end

    def post
      validation.validate
      post_photo
      post_notice
    end

    private

    def post_notice
      validation.muted_notices.each { |notice| SlackPost.execute seeker.im, notice }
    end

    def post_photo
      users.in_local.each { |local| SlackPostPhoto.execute destination, local.last_image }
    end

    def users
      @_users ||= SlackBot::ResponderUsers.new(realtime: realtime, message: message)
    end

    def destination
      @_destination ||= SlackBot::ResponderDestination.new(message: message, source: source, target: target, seeker: seeker).respond
    end

    def validation
      @_validation ||= SlackBot::ResponderValidator.new(users: users, message: message, seeker: seeker)
    end
  end
end
