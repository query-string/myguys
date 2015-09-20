require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/realtime_event"
require "slack_bot/realtime_listener"
require "slack_bot/realtime_public_listener"
require "slack_bot/realtime_private_listener"
require "slack_bot/pg_event"
require "slack_bot/forwarder_powerball"
require "slack_bot/forwarder"
require "slack_bot/sender"

# @TODO: Empty message error
# @TODO: Show us command doesn't work
# @TODO: Send messages other the realtime instance
# @TODO: Attributes :realtime and :realtime_message might be a part of Forwarder class
# @TODO: Remove environment

class SlackBot
  attr_reader :realtime, :realtime_event, :target

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    listen_bus
    #listen_chat
  end

  def listen_chat
    lumos "Listening chat...", position: :bottom, delimiter: "❄"
    @realtime_event = SlackBot::RealtimeEvent.new(realtime)
    @realtime_event.on do |channel_type|
      listener = "SlackBot::Realtime#{channel_type}Listener".constantize.new(
        realtime_attributes.merge(realtime_event: realtime_event)
      )
      reply SlackBot::Forwarder.new(listener) if listener.proper_target_defined?
    end
  end

  def listen_bus
    lumos "Listening PG...", position: :bottom, delimiter: "❄"
    @pg_event = SlackBot::PgEvent.new realtime_attributes
  end

  private

  def realtime_attributes
    {
      realtime:       realtime,
      target:         target
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
