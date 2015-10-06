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
    r = observer_realtime
    b = observer_bus
    r.join
    b.join
  end

  def observer_realtime
    observer = SlackBot::RealtimeObserver.new(realtime_attributes)
    observer.on { |handler_type| handle handler_type, observer }
  end

  def observer_bus
    observer = SlackBot::BusObserver.new(realtime_attributes)
    observer.on { |payload| handle "Slash", JSON.parse(payload).to_hashugar }
  end

  private

  def handle(type, event)
    handler = "SlackBot::#{type}Handler".constantize.new realtime_attributes(event: event)
    SlackBot::Responder.new(handler).respond if handler.proper_target_defined?
  end

  def realtime_attributes(extra = {})
    {realtime: realtime, target: target}.merge(extra)
  end
end
