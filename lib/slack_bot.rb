class SlackBot
  require "slack_bot/environment"
  require "slack_bot/listener"
  require "slack_bot/public_listener"
  require "slack_bot/private_listener"
  require "slack_bot/message_parser"

  include SlackBot::Environment

  attr_reader :attributes, :target_channel

  def initialize(target_channel = "general")
    @target_channel = target_channel
  end

  def start
    client.on :message do |data|
      @data = data
      populate_attributes
      send("listen_#{message_type}") if client_data.type == "message"
    end
    client.start
  end

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
    channel_ids.include?(client_data.channel) ? "public" : "private"
  end

  private

  def client
    @client ||= Slack.realtime
  end

  def client_response
    @client_response ||= client.response.to_hashugar
  end

  def client_data
    @data.to_hashugar
  end

  def populate_attributes
    @attributes = {
      client: client,
      response: client_response,
      data: client_data,
      bot_user: bot_user,
      im_list: im_list,
      target_channel: target_channel
    }.to_hashugar
  end

  def listen_public
    SlackBot::PublicListener.new @attributes
  end

  def listen_private
    SlackBot::PrivateListener.new @attributes
  end
end
