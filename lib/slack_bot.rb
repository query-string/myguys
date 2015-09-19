require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/realtime_event"
require "slack_bot/realtime_listener"
require "slack_bot/realtime_public_listener"
require "slack_bot/realtime_private_listener"
require "slack_bot/forwarder_powerball"
require "slack_bot/forwarder"
require "slack_bot/sender"

# @TODO: Send messages other the realtime instance
# @TODO: Attributes :realtime and :realtime_message might be a part of Forwarder class
# @TODO: Remove environment

CHANNEL       = "slack_bot"
RESET_CHANNEL = "pg_restart"

class SlackBot
  attr_reader :realtime, :realtime_event, :target

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    #listen_bus
    listen_chat
  end

  def listen_chat
    lumos "Listening chat...", position: :bottom, delimiter: "❄"
    @realtime_event = SlackBot::RealtimeEvent.new(realtime)
    @realtime_event.on do |channel_type|
      sender   = SlackBot::Sender.new(realtime: realtime, realtime_event: realtime_event)
      listener = "SlackBot::Realtime#{channel_type}Listener".constantize.new(
        realtime: realtime,
        text:     realtime_event.data.text,
        channel:  realtime_event.data.channel,
        sender:   sender,
        target:   target
      )
       if listener.proper_target_defined?
          forwarder = SlackBot::Forwarder.new(listener)
          reply forwarder
       end
    end
  end

  def listen_bus
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)
      begin
        conn.async_exec "LISTEN #{RESET_CHANNEL}"
        conn.async_exec "LISTEN #{CHANNEL}"
        catch(:break_loop) do
          loop do
            conn.wait_for_notify do |channel, pid, payload|
              p realtime
              p payload
              throw :break_loop if channel == RESET_CHANNEL
            end
          end
        end
      rescue => error
        p [:error, error]
      ensure
        conn.async_exec "UNLISTEN *"
      end
    end
  end

  private

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
