class SlackBot
  # sender_user     - a real (most likely) person, WHO sends the message
  # channel_users   - a list of channel users brought by rtm.start response
  # mentioned_users - an array of users mentioned in message
  class MessageParser
    include SlackBot::Environment
    attr_reader :message, :default_destination, :sender_user, :channel_users, :target, :im_list

    def initialize(message, destination, attributes)
      @message             = message
      @default_destination = destination
      # @TODO: Too many foreign attributes, better change it to native options
      @sender_user         = attributes.message.data.user
      @channel_users       = attributes.realtime.response.users
      @im_list             = attributes.realtime.ims
      @target              = attributes.target
    end

    def response
      @response = if message.present?
        if mentioned_user_ids.size > 0
          { type: :users,
            body: hg_slack_users
          }
        else
          { type: :notice,
            body: no_users_presented
          }
        end
      else
        { type: :notice,
          body: no_message_defined
        }
      end
      @response.merge(destination: destination)
    end

    def destination
      @destination ||= message.present? ? catch_destination : default_destination
    end

    def sender_user_name
      @sender_user_name ||= channel_user_by_id(sender_user)["name"]
    end

    def sender_user_im
      @sender_user_im ||= im_list.find { |im| im.user == sender_user }.id
    end

    private

    def catch_destination
      substr = message.match(/show me|show us/)
      if substr
        substr.to_s.match(/me/) ? sender_user_im : "##{target}"
      else
        default_destination
      end
    end

    def channel_user_by_id(id)
      channel_users.find{ |user| user["id"] == id }
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

    def no_message_defined
      "How can I serve you, my dear @#{sender_user_name}?"
    end

    def no_users_presented
      "Sorry @#{sender_user_name}, your request must contain at least one *@username*"
    end
  end
end
