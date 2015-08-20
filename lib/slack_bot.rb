require "slack_bot/environment"
require "slack_bot/realtime"
require "slack_bot/listener"
require "slack_bot/public_listener"
require "slack_bot/private_listener"
require "slack_bot/message_parser"

# @TODO: User liteners as a message cleaners
# @TODO: Message parser should only parse message, but not define a destination (?)

class SlackBot
  attr_reader :attributes, :data, :realtime, :target_channel

  def initialize(target_channel = "general")
    @realtime       = SlackBot::Realtime.new
    @target_channel = target_channel
  end

  def start
    realtime.client.on :message do |data|
      @data = data.to_hashugar
      populate_attributes
      listen
    end
    realtime.client.start
  end

  private

  def message_type
    realtime.channel_ids.include?(data.channel) ? "public" : "private"
  end

  def populate_attributes
    @attributes = {
      client: realtime,
      response: realtime.response,
      data: data,
      bot_user: realtime.bot,
      im_list: realtime.ims,
      target_channel: target_channel
    }.to_hashugar
  end

  def listen
    case data.type
      when "message"
        SlackBot::PublicListener.new @attributes
      else
        SlackBot::PrivateListener.new @attributes
      end
  end
end
