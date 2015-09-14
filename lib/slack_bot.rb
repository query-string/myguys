require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/realtime_message"
require "slack_bot/filter"
require "slack_bot/public_filter"
require "slack_bot/private_filter"
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
  end

  def listen_chat
    @message = SlackBot::RealtimeMessage.new(realtime)
    @message.on do |channel_type|
      filter = "SlackBot::#{channel_type}Filter".constantize.new(
        realtime:       realtime,
        text:           message.data.text,
        source:         message.data.channel,
        sender_user_im: message.sender_user_im,
        target:         target
      )
       if filter.references
          forwarder = SlackBot::Forwarder.new filter.references.merge(rtm_attributes)
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
