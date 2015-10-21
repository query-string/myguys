class SlackBot
  class Validator
    attr_reader :message, :users

    def initialize(attributes)
      @message = attributes.fetch(:message)
      @users   = attributes.fetch(:users)
    end

    def flag
      validate :notice do
        users.mentioned_ids.any? ? :users : :notice
      end
    end

    def text
      validate text_nousers do
        users.mentioned_ids.any? ? users.with_references : text_empty
      end
    end

    private

    def validate(presence, &references)
      if message.present?
        references.call
      else
        presence
      end
    end

    def text_empty
      "How can I serve you, my dear @#{sender.name}?"
    end

    def text_nousers
      "Sorry @#{sender.name}, your request must contain at least one *@username*"
    end
  end
end
