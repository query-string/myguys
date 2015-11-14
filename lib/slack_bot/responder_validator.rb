class SlackBot
  class ResponderValidator
    attr_reader :message, :users, :seeker, :notices

    def initialize(attributes)
      @message = attributes.fetch(:message)
      @users   = attributes.fetch(:users)
      @seeker  = attributes.fetch(:seeker)
      @notices = []
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
      simplify notices, :body
    end

    def all_subjects
      simplify notices, :subject
    end

    def muted_notices
      if all_subjects.include?(:message_empty) && all_subjects.include?(:user_mentions) && all_subjects.include?(:users_nonexistence)
        simplify notices.select { |notice| notice[:subject] == :message_empty }, :body
      elsif all_subjects.include?(:user_mentions) && all_subjects.include?(:users_nonexistence)
        simplify notices.select { |notice| notice[:subject] == :user_mentions }, :body
      else
        all_notices
      end
    end

    private

    def validate_message_presence
      put_notice notice_empty_message unless message.present?
    end

    def validate_user_mentions
      put_notice notice_user_mentions_omission unless users.mentioned_ids.any?
    end

    def validate_users_existence
      put_notice notice_users_nonexistence if users.local_diff.any?
    end

    def put_notice(notice)
      notices << notice
    end

    def simplify(hash, key)
      hash.map{ |notice| notice[key] }
    end

    def notice_empty_message
      {subject: :message_empty, body: "How can I serve you, my dear @#{seeker.name}?"}
    end

    def notice_user_mentions_omission
      {subject: :user_mentions, body: "Sorry @#{seeker.name}, your request must contain at least one *@username*"}
    end

    def notice_users_nonexistence
      {subject: :users_nonexistence, body: "None of these users have appeared at higuys app yet: *#{users.local_diff.join(", ")}*"}
    end
  end
end
