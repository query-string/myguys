class SlackBot
  module Handlers
    class Slash < SlackBot::Handlers::Base
      def proper_target_defined?
        false
      end
    end
  end
end
