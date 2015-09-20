class SlackBot
  # Filters rtm messages and gives future references if proper target defined
  class RealtimeListener
    # sender    - a real (most likely) person, WHO sends the message
    # bot       - an application user (application bot)
    # recipient - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
    attr_reader :realtime, :realtime_event, :target

    def initialize(attributes)
      @realtime       = attributes.fetch(:realtime)
      @realtime_event = attributes.fetch(:realtime_event)
      @target         = attributes.fetch(:target)
    end

    def text
      realtime_event.data.text
    end

    def channel
      realtime_event.data.channel
    end

    def bot
      realtime.bot
    end

    def sender
      SlackBot::Sender.new(
        realtime: realtime,
        realtime_event: realtime_event
      )
    end
  end
end
