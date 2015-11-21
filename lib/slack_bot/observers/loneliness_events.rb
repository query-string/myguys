class SlackBot
  module Observers
    class LonelinessEvents < SlackBot::Observers::Bus
      def command_channel
        "loneliness_event"
      end

      def hello_message
        "PG Listening for loneliness events..."
      end
    end
  end
end