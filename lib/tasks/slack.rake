namespace :slack do
  desc "Starts hg Slack bot listeneer"
  task listen: :environment do
    client = Slack.realtime
    client.on :message do |data|
      lumos data
      lumos data["text"]
    end
    client.start
  end
end
