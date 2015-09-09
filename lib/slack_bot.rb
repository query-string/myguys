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

class SlackBot
  attr_reader :realtime, :message, :target, :filter, :forwarder

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    @message = SlackBot::RealtimeMessage.new(realtime)
    @message.on do |channel_type|
       @filter = request_filter channel_type
       if filter.references
          @forwarder = request_forwarder
          reply
       end
    end
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
        SlackPost.execute forwarder.destination, forwarder.message
      when :users
        # @TODO: Extract to the Forwarder class as well
        SlackPostPhoto.execute forwarder.destination, forwarder.local_users.first[:user].last_image if forwarder.local_users.any?
      end
  end
end
