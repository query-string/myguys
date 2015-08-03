namespace :slack do
  desc "Starts hg Slack bot listeneer"
  task listen: :environment do
    SlackBot.new.start
  end
end
