require "slack_bot/environment"
require "slack_bot/listener"
require "slack_bot/public_listener"
require "slack_bot/private_listener"
require "slack_bot/message_parser"

# @TODO: Extract client related methods to client class
# @TODO: User liteners as a message cleaners
# @TODO: Message parser should only parse message, but not define a destination (?)

class SlackBot
  include SlackBot::Environment
  attr_reader :attributes, :data

  def initialize(target_channel = "general")
    @target_channel = target_channel
  end

  def start
    client.on :message do |data|
      @data = data.to_hashugar
      populate_attributes
      listen
    end
    client.start
  end

  private

  def bot_user
    client_response.self
  end

  def channel_ids
    client_response.channels.map(&:id)
  end

  def im_list
    client_response.ims
  end

  def message_type
    channel_ids.include?(data.channel) ? "public" : "private"
  end

  def client
    @client ||= Slack.realtime
  end

  def client_response
    @client_response ||= client.response.to_hashugar
  end

  def populate_attributes
    @attributes = {
      client: client,
      response: client_response,
      data: data,
      bot_user: bot_user,
      im_list: im_list,
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
