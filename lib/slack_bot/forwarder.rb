class SlackBot
  # Calculates destination
  # Validates message
  # Returns users
  class Forwarder
    # target          – public channel which listens by default (usually #general)
    # source          – source channel from where message comes ATM (public channel OR PM)
    # mentioned_users - an array of users mentioned in message
    include SlackBot::Environment
    include SlackBot::Forwarder::Powerball

    attr_reader :attributes, :realtime, :realtime_message, :target, :text, :source

    def initialize(attributes)
      @attributes       = attributes

      @realtime         = attributes.fetch(:realtime)
      @realtime_message = attributes.fetch(:realtime_message)
      @text             = attributes.fetch(:text)
      @source           = attributes.fetch(:source)
    end

    def destination
      text.present? ? catch_destination : source
    end

    def sender_user_id
      realtime_message.sender_user_im.id
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
      powerball method.to_sym if POWERBALL_KEYS.include?(method.to_sym)
    end

    def catch_destination
      substr = text.match(/show me|show us/)
      if substr
        substr.to_s.match(/me/) ? sender_user_id : "##{target}"
      else
        source
      end
    end

    def mentioned_user_ids
      text.scan(regex).flatten
    end
  end
end
