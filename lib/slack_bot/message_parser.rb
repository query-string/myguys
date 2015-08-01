class SlackBot
  class MessageParser
    attr_reader :message, :user_id, :regex, :users

    def initialize(message, attibutes)
      @message = message
      @user_id = attibutes.data.user
      @regex   = attibutes.regex
      @users   = attibutes.response.users
    end

    def response
      if message.present?
        if requested_users.size > 0
          requested_user_names
        else
          no_users_presented
        end
      else
        no_message_defined
      end
    end

    def username
      @username ||= find_by_id(user_id)["name"]
    end

    def find_by_id(id)
      users.find{ |user| user["id"] == id }
    end

    def requested_users
      message.scan(regex).flatten
    end

    def requested_user_names
      # Try to find username besides client response Slack users
      requested_users.map{ |user_id| find_by_id(user_id) ? find_by_id(user_id)["name"] : user_id }
    end

    private

    def no_message_defined
      "How can I serve you, my dear @#{username}?"
    end

    def no_users_presented
      "Sorry @#{username}, your request must contain at least one *@username*"
    end
  end
end
