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
      self.send("listen_#{message_type}") if client_data.type == "message"
    end
    client.start
  end

  def bot_user_id
    client_response.self.id
  end

  def channel_ids
    client_response.channels.map(&:id)
  end

  def target_channel_id
    client_response.channels.find{ |channel| channel.name == target_channel }.id
  end

  def original_message
    client_data.text
  end

  def message_type
    channel_ids.include?(client_data.channel) ? "public" : "private"
  end

private

  def client
    @client ||= Slack.realtime
  end

  def client_data
    @client_data ||= Dish(@data)
  end

  def client_response
    @client_response ||= Dish(client.response)
  end

  def populate_attributes
    @attributes = Dish ({
      client: client,
      data: client_data,
      response: client_response,
      message: original_message,
      bot_user_id: bot_user_id,
      target_channel_id: target_channel_id
    })
  end

  def listen_public
    lumos SlackBot::PublicListener.new @attributes
  end

  def listen_private
    lumos SlackBot::PrivateListener.new @attributes
  end

end
