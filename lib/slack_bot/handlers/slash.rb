class SlackBot
  module Handlers
    class Slash < SlackBot::Handlers::Base
      def proper_target_defined?
        true
      end

      def message
        event.text
      end

      def source
        event.channel_id
      end
    end
  end
end
