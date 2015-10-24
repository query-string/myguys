class SlackBot
  class ResponderValidator
    attr_reader :message, :users, :sender, :errors

    def initialize(attributes)
      @message = attributes.fetch(:message)
      @users   = attributes.fetch(:users)
      @sender  = attributes.fetch(:sender)
      @errors  = []
    end

    def validate
      validate_message_presence && validate_user_mentions && validate_user_existence
    end

    def successful?
      errors.size == 0
    end

    def error_message
      errors.last
    end

    def validate_message_presence
      errors << notice_empty_message unless message.present?
    end

    def validate_user_mentions
      errors << notice_user_omission unless users.mentioned_ids.any?
    end

    def validate_user_existence
      errors << notice_user_ unless users.in_local.any?
    end

    private

    def notice_empty_message
      "How can I serve you, my dear @#{sender.name}?"
    end

    def notice_user_mentions
      "Sorry @#{sender.name}, your request must contain at least one *@username*"
    end

    def notice_user_unexistence
      "None of requested users has appeared at higuys yet ("
    end
  end
end
