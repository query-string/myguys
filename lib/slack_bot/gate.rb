class SlackBot
  # sender_user    - a real (most likely) person, WHO sends the message
  # recipient_user - a message recipient, WHOM has been mentioned at the first part of data.text (i.e. @higuys: or whatever)
  # bot_user       - an application user (application bot)
  class Gate
    attr_reader :attributes, :realtime, :message, :target, :bot_user, :text, :channel

    def initialize(attributes)
      @attributes   = attributes
      @realtime     = attributes.fetch(:realtime)
      @message      = attributes.fetch(:message)
      @target       = attributes.fetch(:target)

      @bot_user     = realtime.bot
      @text         = message.data.text
      @channel      = message.data.channel
    end

    def coordinates
      if proper_target_selected?
        {
          text: gate_text,
          channel: gate_channel
        }
      end
    end

    private

    def listen
      case parser[:type]
        when :notice
          SlackPost.execute parser[:destination], parser[:body]
        when :users
          hg_users = parser[:body].select { |user| user[:type] == :hg }
          SlackPostPhoto.execute parser[:destination], hg_users.first[:user].last_image if hg_users.size > 0
        end
    end

  end
end
