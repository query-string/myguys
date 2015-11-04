class SlackBot
  class Sender
    attr_reader :realtime, :event

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      @event    = attributes.fetch(:event)
    end

    def user
      event.user
    end

    def im
      realtime.ims.find { |im| im.user == user }
    end

    def name
      event.try(:user_name).present? ? event.user_name : realtime.team_user_by_id(user).name
    end

    def id
      event.try(:user_id).present? ? event.user_id : im.try(:id)
    end
  end
end
