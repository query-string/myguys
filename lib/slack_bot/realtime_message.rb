class SlackBot
  class RealtimeMessage
    attr_reader :realtime, :client, :data

    def initialize(realtime)
      @realtime = realtime
      @client   = realtime.client
    end

    def on(&block)
      client.on :message do |data|
        @data = data.to_hashugar
        block.call type if block_given?
      end
      client.start
    end

    def type
      realtime.channel_ids.include?(data.channel) ? "Public" : "Private"
    end

    def sender_user
      data.user
    end

    def sender_user_im
      realtime.ims.find { |im| im.user == sender_user }
    end

    def proper_for_private?
      data.channel == sender_user_im.try(:id)
    end
  end
end
