class SlackBot
  class MessageParser
    attr_reader :message, :user_id

    def initialize(message, user_id)
      @message  = message
      @user_id  = user_id
    end

    def response
      if message.present?
      else
        no_message_present
      end
    end

    private

    def no_message_present
      "How can I serve you, my dear @#{username}?"
    end

    def username
      @username ||= Slack.users_info(user: user_id)["user"]["name"]
    end
  end
end
