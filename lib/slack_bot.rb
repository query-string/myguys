require "slack_bot/environment"
require "slack_bot/realtime"

require "slack_bot/event/event"
require "slack_bot/event/realtime_event"
require "slack_bot/event/bus_event"
require "slack_bot/filter/filter"
require "slack_bot/filter/public_filter"
require "slack_bot/filter/private_filter"
require "slack_bot/filter/slash_filter"

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
    r = event_realtime
    b = event_bus
    r.join
    b.join
  end

  def event_realtime
    event = SlackBot::RealtimeEvent.new(realtime_attributes)
    event.on { |filter_type| handler filter_type, event }
  end

  def event_bus
    event = SlackBot::BusEvent.new(realtime_attributes)
    event.on { handler "Slash" }
  end

  private

  def handler(type, realtime_event = nil)
    filter_attr = realtime_event.present? ? realtime_attributes.merge(realtime_event: realtime_event) : realtime_attributes
    filter      = "SlackBot::#{type}Filter".constantize.new filter_attr

    reply SlackBot::Forwarder.new(filter) if filter.proper_target_defined?
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
