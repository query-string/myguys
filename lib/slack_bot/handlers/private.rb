class SlackBot
  module Handlers
    class Private < SlackBot::Handlers::Base
      def message
        text
      end

      def source
        channel
      end

      def proper_target_defined?
        channel == sender.id
      end
    end
  end
end