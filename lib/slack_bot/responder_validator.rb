class SlackBot
  class ResponderValidator
    attr_reader :message, :users, :sender, :error_messages

    def initialize(attributes)
      @message         = attributes.fetch(:message)
      @users           = attributes.fetch(:users)
      @sender          = attributes.fetch(:sender)
      @error_messages  = []
    end

    def validate
      validate_message_presence
      validate_user_mentions
      validate_user_existence
    end

    def successful?
      error_messages.size == 0
    end

    def validate_message_presence
      put_error_message notice_empty_message unless message.present?
    end

    def validate_user_mentions
      put_error_message notice_user_omission unless users.mentioned_ids.any?
    end

    def validate_user_existence
      put_error_message notice_user_unexistence unless users.in_local.any?
    end

    def put_error_message(message)
      error_messages << message
    end

    private

    def notice_empty_message
      "How can I serve you, my dear @#{sender.name}?"
    end

    def notice_user_omission
      "Sorry @#{sender.name}, your request must contain at least one *@username*"
    end

    def notice_user_unexistence
      "None of requested users has appeared at higuys yet ("
    end
  end
end
