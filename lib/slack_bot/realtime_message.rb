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
  end
end
