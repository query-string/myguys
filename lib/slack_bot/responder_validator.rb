class SlackBot
  class Validator
    attr_reader :message, :users

    def initialize(attributes)
      @message = attributes.fetch(:message)
      @users   = attributes.fetch(:users)
    end

    def flag
      if message.present?
        users.mentioned_ids.any? ? :users : :notice
      else
        :notice
      end
    end

    def text
      if message.present?
        users.mentioned_ids.any? ? users.with_references : text_empty
      else
        text_nousers
      end
    end

    private

    def text_empty
      "How can I serve you, my dear @#{sender.name}?"
    end

    def text_nousers
      "Sorry @#{sender.name}, your request must contain at least one *@username*"
    end
  end
end
