require "slack_bot/environment"
require "slack_bot/realtime"

require "slack_bot/observers/observer"
require "slack_bot/observers/realtime_observer"
require "slack_bot/observers/bus_observer"
require "slack_bot/handlers/handler"
require "slack_bot/handlers/public_handler"
require "slack_bot/handlers/private_handler"
require "slack_bot/handlers/slash_handler"

require "slack_bot/sender"
require "slack_bot/responder"

# @TODO: Empty message error
# @TODO: Show us command doesn't work
# @TODO: Send messages other the realtime instance
# @TODO: Attributes :realtime and :realtime_message might be a part of Forwarder class
# @TODO: Remove environment

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
    observer = "#{name}_observer"
    define_method(observer) do
      "SlackBot::#{observer.camelize}".constantize.new(realtime_attributes)
    end
  end

  # Handler methods: slash_handler(event)
  %i(private public slash).each do |name|
    handler = "#{name}_handler"
    define_method(handler) do |event|
      # TODO: Do we really have to pass realtime_attributes here?
      "SlackBot::#{handler.camelize}".constantize.new realtime_attributes(event: event)
    end
  end
end
