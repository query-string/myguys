class SlackBot
  # sender_user     - a real (most likely) person, WHO sends the message
  # channel_users   - a list of channel users brought by rtm.start response
  # mentioned_users - an array of users mentioned in message
  class MessageParser
    attr_reader :message, :sender_user, :channel_users, :regex

    def initialize(message, attibutes)
      @message       = message
      @regex         = attibutes.regex
      @sender_user   = attibutes.data.user
      @channel_users = attibutes.response.users
    end

    def response
      if message.present?
        if mentioned_user_ids.size > 0
          { type: :users,
            body: hg_slack_users
          }
        else
          { type: :message,
            body: no_users_presented
          }
        end
      else
        { type: :message,
          body: no_message_defined
        }
      end
    end

    def channel_user_by_id(id)
      channel_users.find{ |user| user["id"] == id }
    end

    def sender_user_name
      @sender_user_name ||= channel_user_by_id(sender_user)["name"]
    end

    def mentioned_user_ids
      message.scan(regex).flatten
    end

    def mentioned_users
      # Try to find username besides Slack responded users
      mentioned_user_ids.map { |user| channel_user_by_id(user) ? channel_user_by_id(user)["name"] : user }
    end

    def hg_slack_users
      # Try to find hg users
      mentioned_users.map { |user|
        hg_user = User.with_nickname(user).by_the_latest_photo.first
        hg_user ? {type: :hg, user: hg_user} : {type: :slack, user: user}
      }
    end

    private

    def no_message_defined
      "How can I serve you, my dear @#{sender_user_name}?"
    end

    def no_users_presented
      "Sorry @#{sender_user_name}, your request must contain at least one *@username*"
    end
  end
end
