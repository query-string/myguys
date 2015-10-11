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
          SlackPostPhoto.execute destination, local_users.first[:user].last_image if local_users.any?
        end
    end

    def destination
      message.present? ? catch_destination : source
    end

    def mentioned_users
      mentioned_user_ids.map do |user|
        team_user = realtime.team_user_by_id user
        team_user ? team_user.name : user
      end
    end

    def mentioned_users_with_references
      mentioned_users.map do |slack_user|
        local_user = User.with_nickname(slack_user).by_the_latest_photo.first
        local_user ? {found_in: :local, user: local_user} : {found_in: :slack, user: slack_user}
      end
    end

    def slack_users
      mentioned_users_with_references.select { |user| user[:found_in] == :slack }
    end

    def local_users
      mentioned_users_with_references.select { |user| user[:found_in] == :local }
    end

    private

    def method_missing(method)
      POWERBALL_KEYS.include?(method.to_sym) ? powerball(method.to_sym) : super
    end

    def catch_destination
      substr = message.match(/show me|show us/)
      if substr
        substr.to_s.match(/me/) ? sender.id : "##{target}"
      else
        source
      end
    end

    def mentioned_user_ids
      message.scan(realtime.regex).flatten
    end

    def powerball(attr)
      response = if message.present?
        mentioned_user_ids.any? ? [:users, mentioned_users_with_references] : [:notice, powerball_notice_empty]
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
