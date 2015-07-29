class SlackBot
  class PublicListener
    attr_reader :attributes, :data, :response, :target_channel

    def initialize(attributes)
      @attributes     = attributes
      @data           = attributes.data
      @response       = attributes.response
      @target_channel = attributes.target_channel

      # If channel is target channel
      # If first part of messge – is username
      # If requested user id is equal to bot user id
      listen if channel == target_channel_id && user =~ attributes.regex && user_id == attributes.bot_user.id
    end

    def message
      data.text
    end

    def splitted_message
      message.split(":")
    end

    def text
      splitted_message[1]
    end

    def user
      splitted_message[0]
    end

    def user_id
      user.match(attributes.regex).captures.join
    end

    def channel
      data.channel
    end

    def target_channel_id
      response.channels.find { |channel| channel.name == target_channel }.id
    end

    private

    def listen
      lumos text
    end
  end
end
