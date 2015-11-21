class SlackBot
  module Observers
    class SlashEvents < SlackBot::Observers::Bus
      def command_channel
        "slash_event"
      end

      def hello_message
        "PG Listening for slash commands..."
      end
    end
  end
end