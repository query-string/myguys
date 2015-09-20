class SlackBot
  class RealtimePublicListener < RealtimeListener
    include SlackBot::Environment

    def message
      splitted_text[1].to_s.strip
    end

    def source
      "##{target}"
    end

    def proper_target_defined?
      # If channel is a target channel
      # If first part of messge – is a username
      # If requested user id is equal to bot user id
      channel == target_channel_id && recipient =~ regex && recipient_id == bot.id
    end

    private

    def splitted_text
      text.split(":")
    end


    def recipient
      splitted_text[0]
    end

    def recipient_id
      recipient.match(regex).captures.join
    end

    def target_channel_id
      realtime.find_channel(target).try(:id)
    end
  end
end
