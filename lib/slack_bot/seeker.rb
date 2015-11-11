class SlackBot
  class Seeker
    attr_reader :realtime, :event

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      @event    = attributes.fetch(:event)
    end

    def id
      event.try(:user_id).present? ? event.user_id : event.user
    end

    def name
      event.try(:user_name).present? ? event.user_name : realtime.team_user_by_id(id).name
    end

    def im
      realtime.ims.find { |im| im.user == id }.try(:id)
    end
  end
end
