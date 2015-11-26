class SlackBot
  module Observers
    class SlashNotifications < SlackBot::Observers::Bus
      def command_channel
        "slash_notification"
      end

      def hello_message
        "PG Listening for slash commands..."
      end
    end
  end
end