class SlackBot
  class Notifier
    attr_reader :target, :payload

    def initialize(target, payload)
      @target  = target
      @payload = payload.to_json
    end

    def notify
      ActiveRecord::Base.connection.execute %Q(NOTIFY "#{target}", '#{payload}')
    end
  end
end