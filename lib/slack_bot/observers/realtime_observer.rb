class SlackBot
  class RealtimeObserver < Observer
    attr_reader :realtime, :client, :data

    def initialize(attributes, &callback)
      @client = attributes.fetch(:realtime).client
      super
    end

    def channel
      data.channel
    end

    def text
      data.text
    end

    private

    def hello_message
      "Listening chat..."
    end

    def listen
      client.on :message do |data|
        @data = data.to_hashugar
        callback.call type
      end
      client.start
    end

    def type
      realtime.channel_ids.include?(data.channel) ? "Public" : "Private"
    end
  end
end
