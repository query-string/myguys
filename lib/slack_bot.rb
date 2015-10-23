require "slack_bot/realtime"

require "slack_bot/observers/base"
require "slack_bot/observers/realtime"
require "slack_bot/observers/bus"

require "slack_bot/handlers/base"
require "slack_bot/handlers/public"
require "slack_bot/handlers/private"
require "slack_bot/handlers/slash"

require "slack_bot/sender"
require "slack_bot/responder_destination"
require "slack_bot/responder_users"
require "slack_bot/responder_validator"
require "slack_bot/responder"

# @TODO: Notice about unexisted users
# @TODO: PM as destination for notice
# @TODO: Send messages other the realtime instance
# @TODO: Send aplication photo via realtime instance

class SlackBot
  attr_reader :realtime, :target

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    r = observe_realtime
    b = observe_bus
    r.join
    b.join
  end

  def observe_realtime
    observer = realtime_observer
    observer.on do |response|
      SlackBot::Responder.new(
        send("#{response}_handler", observer)
      ).respond
    end
  end

  def observe_bus
    bus_observer.on do |response|
      SlackBot::Responder.new(
        slash_handler(JSON.parse(response).to_hashugar)
      ).respond
    end
  end

  private

  def realtime_attributes(extra = {})
    {realtime: realtime, target: target}.merge(extra)
  end

  # Obsever methods: relatime_observer
  %i(realtime bus).each do |name|
    define_method("#{name}_observer") do
      "SlackBot::Observers::#{name.capitalize}".constantize.new(realtime_attributes)
    end
  end

  # Handler methods: slash_handler(event)
  %i(private public slash).each do |name|
    define_method("#{name}_handler") do |event|
      "SlackBot::Handlers::#{name.capitalize}".constantize.new realtime_attributes(event: event)
    end
  end
end
