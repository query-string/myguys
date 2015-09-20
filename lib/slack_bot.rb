require "slack_bot/environment"
require "slack_bot/realtime"

require "slack_bot/event/event"
require "slack_bot/event/realtime_event"
require "slack_bot/event/bus_event"

require "slack_bot/realtime_listener"
require "slack_bot/realtime_public_listener"
require "slack_bot/realtime_private_listener"
require "slack_bot/forwarder_powerball"
require "slack_bot/forwarder"
require "slack_bot/sender"

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
    event_bus
    event_realtime
  end

  def event_realtime
    event = SlackBot::RealtimeEvent.new(realtime)
    event.on do |channel_type|
      listener = realtime_listener(channel_type)
      reply SlackBot::Forwarder.new(listener) if listener.proper_target_defined?
    end
  end

  def event_bus
    event = SlackBot::BusEvent.new realtime_attributes
  end

  private

  def realtime_listener(channel_type)
    "SlackBot::Realtime#{channel_type}Listener".constantize.new(
      realtime_attributes.merge(realtime_event: event)
    )
  end

  def realtime_attributes
    {
      realtime: realtime,
      target:   target
    }
  end

  def reply(forwarder)
    case forwarder.flag
      when :notice
        SlackPost.execute forwarder.destination, forwarder.event
      when :users
        # @TODO: Extract to the Forwarder class as well
        SlackPostPhoto.execute forwarder.destination, forwarder.local_users.first[:user].last_image if forwarder.local_users.any?
      end
  end
end
