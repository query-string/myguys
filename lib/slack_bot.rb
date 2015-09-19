require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/realtime_message"
require "slack_bot/realtime_listener"
require "slack_bot/realtime_public_listener"
require "slack_bot/realtime_private_listener"
require "slack_bot/forwarder_powerball"
require "slack_bot/forwarder"

# @TODO: Send messages other the realtime instance
# @TODO: Attributes :realtime and :realtime_message might be a part of Forwarder class
# @TODO: Remove environment

CHANNEL       = "slack_bot"
RESET_CHANNEL = "pg_restart"

class SlackBot
  attr_reader :realtime, :message, :target

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    #listen_bus
    listen_chat
    p "Listening..."
  end

  def listen_chat
    @message = SlackBot::RealtimeMessage.new(realtime)
    @message.on do |channel_type|
      listener = "SlackBot::Realtime#{channel_type}Listener".constantize.new(
        realtime:       realtime,
        text:           message.data.text,
        source:         message.data.channel,
        sender_user_im: message.sender_user_im,
        target:         target
      )
       if listener.references
          forwarder = SlackBot::Forwarder.new listener.references.merge(rtm_attributes)
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

  def rtm_attributes
    {
      realtime:         realtime,
      realtime_message: message,
      target:           target
    }
  end

  def reply(forwarder)
    case forwarder.flag
      when :notice
        SlackPost.execute forwarder.destination, forwarder.message
      when :users
        # @TODO: Extract to the Forwarder class as well
        SlackPostPhoto.execute forwarder.destination, forwarder.local_users.first[:user].last_image if forwarder.local_users.any?
      end
  end
end
