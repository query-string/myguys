class SlackBot
  module Handlers
    class Private < SlackBot::Handlers::Base
      def message
        text.gsub("<@#{bot.id}>", "")
      end

      def source
        channel
      end

      def proper_target_defined?
        channel == seeker.im
      end
    end
  end
end
