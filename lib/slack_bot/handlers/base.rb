class SlackBot
  # Filters rtm messages and gives future references if proper target defined
  module Handlers
    class Base
      # seeker    - a real (most likely) person, WHO sends the message
      # bot       - an application user (application bot)
      # recipient - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
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
