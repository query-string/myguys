class SlackBot
  # Filters rtm messages and gives future references if proper target defined
  class Handler
    # sender    - a real (most likely) person, WHO sends the message
    # bot       - an application user (application bot)
    # recipient - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
    attr_reader :realtime, :event, :target

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      @event    = attributes.fetch(:event)
      @target   = attributes.fetch(:target)
    end

    def text
      event.text
    end

    def channel
      event.channel
    end

    def bot
      realtime.bot
    end

    def sender
      SlackBot::Sender.new(
        realtime: realtime,
        realtime_event: event
      )
    end
  end
end
