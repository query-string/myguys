class SlackBot
  module Handlers
    class Base
      attr_reader :realtime, :event, :target, :seeker

      def initialize(attributes)
        @realtime = attributes.fetch(:realtime)
        @event    = attributes.fetch(:event)
        @target   = attributes.fetch(:target)
        @seeker   = SlackBot::Seeker.new(realtime: realtime, event: event)
      end

      def bot
        realtime.bot
      end

      def text
        event.text
      end

      def channel
        event.channel
      end
    end
  end
end
