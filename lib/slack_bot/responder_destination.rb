class SlackBot
  class ResponderDestination
    attr_reader :message, :source, :target, :sender

    def initialize(attributes)
      @message = attributes.fetch(:message)
      @source  = attributes.fetch(:source)
      @target  = attributes.fetch(:target)
      @sender  = attributes.fetch(:sender)
    end

    def respond
      message.present? ? catch_destination : source
    end

    def substr
      message.match(/show me|show us/)
    end

    def catch_destination
      if substr
        substr.to_s.match(/me/) ? sender.im : "##{target}"
      else
        source
      end
    end
  end
end
