require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/realtime_message"
require "slack_bot/gate"
require "slack_bot/public_gate"
require "slack_bot/private_gate"
require "slack_bot/message_parser"

# @TODO: Use liteners as a message cleaners
# @TODO: Message parser should only parse message, but not define a destination (?)
# @TODO: Remove environment

class SlackBot
  attr_reader :realtime, :message, :target, :gate

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    @message = SlackBot::RealtimeMessage.new(realtime)
    @message.on do |type|
       @gate = request_gate type
       p gate.coordinates
    end
  end

  private

  def request_gate(gate_type)
    "SlackBot::#{gate_type}Gate".constantize.new ({
      realtime: realtime,
      message: message,
      target: target
    })
  end
end
