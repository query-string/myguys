class SlackBot
  class Realtime
    attr_reader :client, :response

    def initialize
      @client ||= Slack.realtime
    end

    def response
      @response ||= client.response.to_hashugar
    end

    def bot
      response.self
    end

    def ims
      response.ims
    end

    def channel_ids
      response.channels.map(&:id)
    end
  end
end
