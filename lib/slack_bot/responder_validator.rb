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
      validate_users_existence
    end

    def successful?
      error_messages.size == 0
    end

    def validate_message_presence
      put_error_message notice_empty_message unless message.present?
    end

    def validate_user_mentions
      put_error_message notice_user_mentions_omission unless users.mentioned_ids.any?
    end

    def validate_users_existence
      put_error_message notice_users_unexistence unless users.in_local.any?
    end

    def put_error_message(notice)
      error_messages << notice
    end

    private

    def notice_empty_message
      {subject: :message_empty, body: "How can I serve you, my dear @#{sender.name}?"}
    end

    def notice_user_mentions_omission
      {subject: :user_mentions, body: "Sorry @#{sender.name}, your request must contain at least one *@username*"}
    end

    def notice_users_unexistence
      {subject: :users_unexistens, body: "None of requested users has appeared at higuys yet ("}
    end
  end
end
