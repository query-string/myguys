class SlackBot
  require "slack_bot/public_listener"
  require "slack_bot/private_listener"

  attr_reader :attributes, :target_channel

  REGEX = /@([A-Za-z0-9_-]+)/i

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
    Dish(@data)
  end

  def populate_attributes
    @attributes = {
      client: client,
      response: client_response,
      data: client_data,
      bot_user: bot_user,
      target_channel: target_channel,
      regex: REGEX
    }.to_hashugar
  end

  def listen_public
    SlackBot::PublicListener.new @attributes
  end

  def listen_private
    SlackBot::PrivateListener.new @attributes
  end
end
