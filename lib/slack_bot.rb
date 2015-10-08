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
      handler = send("#{response}_handler", observer)
      SlackBot::Responder.new(handler).respond if handler.proper_target_defined?
    end
  end

  def observe_bus
    bus_observer.on do |response|
      handler = slash_handler(JSON.parse(response).to_hashugar)
      SlackBot::Responder.new(handler).respond if handler.proper_target_defined?
    end
  end

  private

  def realtime_attributes(extra = {})
    {realtime: realtime, target: target}.merge(extra)
  end

  %i(realtime bus).each do |name|
    observer = "#{name}_observer"
    define_method(observer) do
      "SlackBot::#{observer.camelize}".constantize.new(realtime_attributes)
    end
  end

  %i(private public slash).each do |name|
    handler = "#{name}_handler"
    define_method(handler) do |event|
      "SlackBot::#{handler.camelize}".constantize.new realtime_attributes(event: event)
    end
  end
end
