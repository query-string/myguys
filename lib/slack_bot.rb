require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/realtime_message"
require "slack_bot/listener"
require "slack_bot/public_listener"
require "slack_bot/private_listener"
require "slack_bot/message_parser"

# @TODO: Move rtm.data methods from service classes to `SlackBot::RealtimeMessage`
# @TODO: User liteners as a message cleaners
# @TODO: Message parser should only parse message, but not define a destination (?)
# @TODO: Remove environment

class SlackBot
  attr_reader :realtime, :message, :target

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    @message = SlackBot::RealtimeMessage.new(realtime)
    @message.on do |type|
      listen type
    end
  end

  private

  def listen(listener_type)
    "SlackBot::#{listener_type}Listener".constantize.new ({
      client: realtime,
      data: message.data,
      target_channel: target
    }.to_hashugar)
  end
end
