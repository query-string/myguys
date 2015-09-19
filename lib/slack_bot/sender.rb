class SlackBot
  class Sender
    attr_reader :realtime, :realtime_event

    def initialize(attributes)
      @realtime       = attributes.fetch(:realtime)
      @realtime_event = attributes.fetch(:realtime_event)
    end

    def user
      realtime_event.data.user
    end

    def name
      realtime.team_user_by_id(user).name
    end

    def im
      realtime.ims.find { |im| im.user == user }
    end
  end
end
