require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/realtime_message"
require "slack_bot/filter"
require "slack_bot/public_filter"
require "slack_bot/private_filter"
require "slack_bot/forwarder"

# @TODO: Message parser should only parse message, but not define a destination (?)
# @TODO: Remove environment

class SlackBot
  attr_reader :realtime, :message, :target, :filter, :forwarder

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def rtm_attributes
    {
      realtime: realtime,
      realtime_message: message,
      target: target
    }
  end

  def start
    @message = SlackBot::RealtimeMessage.new(realtime)
    @message.on do |type|
       @filter = request_filter type
       if filter.references
          @forwarder = request_forwarder
          p @forwarder.destination
          p @forwarder.mark
          p @forwarder.message
          p @forwarder.mentioned_users
       end
    end
  end

  private

  def request_filter(filter_type)
    "SlackBot::#{filter_type}Filter".constantize.new rtm_attributes
  end

  def request_forwarder
    SlackBot::Forwarder.new filter.references.merge(rtm_attributes)
  end
end
