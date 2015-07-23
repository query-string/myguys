namespace :slack do
  desc "Starts hg Slack bot listeneer"
  task listen: :environment do
    client = Slack.realtime
    client.on :message do |data|
      if data["type"] == "message"

        regex        = /<@([A-Za-z0-9_-]+)>/i
        message      = data["text"].split(":")
        message_user = message[0]

        # If first part of the message contains Slack username
        if message_user =~ regex
          bot_user_id     = client.response["self"]["id"]
          message_user_id = message_user.match(regex).captures.join

          # If mentioned user ID and Slack bot ID are equal
          if bot_user_id == message_user_id
            requested_users = message[1].scan(regex).flatten
          end
        end

      end
    end
    client.start
  end
end
