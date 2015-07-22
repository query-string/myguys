namespace :slack do
  desc "Starts hg Slack bot listeneer"
  task listen: :environment do
    client = Slack.realtime
    client.on :message do |data|
      if data["type"] == "message"
        # Listen mentions
        mention_text = data["text"].split(">:")

        if mention_text.size > 0
          mentioned_message = mention_text[1]
          mentioned_user_id = mention_text[0][2..-1]
          bot_user_id       = client.response["self"]["id"]

          # Compare mentioned user ID with API user ID
          p mentioned_message.strip if mentioned_user_id == bot_user_id
        end
      end
    end
    client.start
  end
end
