class SlackBot
  class ResponderValidator
    attr_reader :message, :users, :sender, :notices

    def initialize(attributes)
      @message         = attributes.fetch(:message)
      @users           = attributes.fetch(:users)
      @sender          = attributes.fetch(:sender)
      @notices  = []
    end

    def validate
      validate_message_presence
      validate_user_mentions
      validate_users_existence
    end

    def successful?
      notices.size == 0
    end

    def all_notices
      notices.map{ |notice| notice[:body] }
    end

    def notice_subjects
      notices.map{ |notice| notice[:subject] }
    end

    private

    def validate_message_presence
      put_notice notice_empty_message unless message.present?
    end

    def validate_user_mentions
      put_notice notice_user_mentions_omission unless users.mentioned_ids.any?
    end

    def validate_users_existence
      put_notice notice_users_unexistence unless users.in_local.any?
    end

    def put_notice(notice)
      notices << notice
    end

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
