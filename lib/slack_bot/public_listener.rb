class SlackBot
  class PublicListener
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def splitted_message
      attributes.message.split(":")
    end

    def user
      splitted_message[0]
    end

    def text
      splitted_message[1]
    end
  end
end
