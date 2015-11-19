class SlackBot
  module Observers
    class BusSlash < SlackBot::Observers::Bus
      def command_channel
        "slash_command"
      end

      def hello_message
        "PG Listening for slash commands..."
      end
    end
  end
end