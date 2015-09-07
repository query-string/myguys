require "slack_bot/environment"
require "slack_bot/slash_command_listener"
require "slack_bot/realtime"
require "slack_bot/realtime_message"
require "slack_bot/filter"
require "slack_bot/public_filter"
require "slack_bot/private_filter"
require "slack_bot/forwarder_powerball"
require "slack_bot/forwarder"

# @TODO: Message parser should only parse message, but not define a destination (?)
# @TODO: Remove environment

class SlackBot
  attr_reader :realtime, :message, :target, :filter, :forwarder

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    listen_chat
    listen_queue
  end

  def listen_chat
    @message = SlackBot::RealtimeMessage.new(realtime)
    @message.on do |type|
       @filter = request_filter type
       if filter.references
          @forwarder = request_forwarder
          reply
       end
    end
  end

  def listen_queue
    Wisper.subscribe(SlackBot::SlashCommandListener.new)
  end

  private

  def rtm_attributes
    {
      realtime: realtime,
      realtime_message: message,
      target: target
    }
  end

  def request_filter(filter_type)
    "SlackBot::#{filter_type}Filter".constantize.new rtm_attributes
  end

  def request_forwarder
    SlackBot::Forwarder.new filter.references.merge(rtm_attributes)
  end

  def reply
    case forwarder.flag
      when :notice
        SlackPost.execute forwarder.destination, forwarder.body
      when :users
        SlackPostPhoto.execute forwarder.destination, forwarder.local_users.first[:user].last_image if forwarder.local_users.any?
      end
  end
end
