class SlackBot

  attr_reader :target_channel

  REGEX = /@([A-Za-z0-9_-]+)/i

  def initialize(target_channel = "general")
    @target_channel = target_channel
  end

  def start
    client.on :message do |data|
      @data = data
      self.send("listen_#{message_type}") if client_data.type == "message"
    end
    client.start
  end

  def target_channel_id
    client_response.channels.find{ |channel| channel.name == target_channel }.id
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

  def client_data
    Dish(@data)
  end

  def client_response
    Dish(client.response)
  end

  def listen_public
    p "public"
  end

  def listen_private
    p "private"
  end

end
