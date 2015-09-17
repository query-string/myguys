class SlackBot
  class RealtimeEvent
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

    def sender_user_name
      realtime.team_user_by_id(sender_user).name
    end

    def sender_user_im
      realtime.ims.find { |im| im.user == sender_user }
    end
  end
end
