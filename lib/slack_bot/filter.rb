class SlackBot
  # Filters rtm messages and gives future references if proper target defined
  class Filter
    # sender_user    - a real (most likely) person, WHO sends the message
    # recipient_user - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
    # bot_user       - an application user (application bot)
    attr_reader :attributes, :realtime, :realtime_message, :target,
                :text, :source, :bot_user

    def initialize(attributes)
      @attributes       = attributes

      @realtime         = attributes.fetch(:realtime)
      @realtime_message = attributes.fetch(:realtime_message)
      @target           = attributes.fetch(:target)

      @text             = realtime_message.data.text
      @channel          = realtime_message.data.channel
      @bot_user         = realtime.bot
    end

    def gate_text
      text
    end

    def gate_source
      source
    end

    def references
      if proper_target_defined?
        {
          text:   gate_text,
          source: gate_source
        }
      end
    end
  end
end
