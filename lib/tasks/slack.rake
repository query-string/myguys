namespace :slack do
  desc "Starts hg Slack bot listeneer"
  task listen: :environment do
    client = Slack.realtime
    client.on :message do |data|
      if data["type"] == "message"

        regex        = /@([A-Za-z0-9_-]+)/i
        message      = data["text"].split(":")
        message_user = message[0]
        message_text = message[1]

        # If first part of the message contains a Slack username
        if message_user =~ regex
          bot_user_id     = client.response["self"]["id"]
          message_user_id = message_user.match(regex).captures.join

          # If mentioned user ID and Slack bot ID are equal
          if bot_user_id == message_user_id
            user_info       = Slack.users_info(user: data["user"])
            user_info_name  = user_info["user"]["name"]

            # Make sure the text is not empty
            if message_text.present?
              requested_users = message_text.scan(regex).flatten

              # Make sure that usernames array is not empty
              if requested_users.size > 0
                # Get photos
                p requested_users
              else
                SlackPost.execute "Sorry @#{user_info_name}, your request must contain at least one *@username*"
              end
            else
              SlackPost.execute "Yes, my dear @#{user_info_name}?"
            end
          end
        end

      end
    end
    client.start
  end
end
