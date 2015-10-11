class SlackBot
  class Realtime
    attr_reader :client, :response, :regex

    def initialize
      @client ||= Slack.realtime
      @regex = /@([A-Za-z0-9_-]+)/i
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

    def team_users
      response.users
    end

    def team_user_by_id(id)
      team_users.find { |user| user.id == id }
    end

    def find_channel(channel_name)
      response.channels.find { |channel| channel.name == channel_name }
    end

  end
end
