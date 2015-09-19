class SlackBot
  # Filters rtm messages and gives future references if proper target defined
  class RealtimeListener
    # sender_user    - a real (most likely) person, WHO sends the message
    # recipient_user - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
    # bot_user       - an application user (application bot)
    attr_reader :realtime, :text, :channel, :sender, :target,
                :bot_user

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      @target   = attributes.fetch(:target)
      @text     = attributes.fetch(:text)
      @channel  = attributes.fetch(:channel)
      @sender   = attributes.fetch(:sender)
      @bot_user = realtime.bot
    end
  end
end
