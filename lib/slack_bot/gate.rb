class SlackBot
  # sender_user    - a real (most likely) person, WHO sends the message
  # recipient_user - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
  # bot_user       - an application user (application bot)
  class Gate
    attr_reader :attributes, :realtime, :realtime_message, :target, :bot_user, :text, :channel

    def initialize(attributes)
      @attributes       = attributes

      @realtime         = attributes.fetch(:realtime)
      @realtime_message = attributes.fetch(:realtime_message)
      @target           = attributes.fetch(:target)

      @bot_user         = realtime.bot
      @text             = realtime_message.data.text
      @channel          = realtime_message.data.channel
    end

    def gate_text
      text
    end

    def gate_source
      channel
    end

    def coordinates
      if proper_target_selected?
        OpenStruct.new(
          text:   gate_text,
          source: gate_source
        )
      end
    end
  end
end
