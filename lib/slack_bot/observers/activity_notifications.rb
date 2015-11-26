class SlackBot
  module Observers
    class ActivityNotifications < SlackBot::Observers::Bus
      def command_channel
        "activity_notification"
      end

      def hello_message
        "PG Listening for activity events..."
      end
    end
  end
end