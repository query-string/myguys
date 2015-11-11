class SlackBot
  class ResponderDestination
    attr_reader :message, :source, :target, :seeker

    def initialize(attributes)
      @message = attributes.fetch(:message)
      @source  = attributes.fetch(:source)
      @target  = attributes.fetch(:target)
      @seeker  = attributes.fetch(:seeker)
    end

    def respond
      message.present? ? catch_destination : source
    end

    def substr
      message.match(/show me|show us/i)
    end

    def catch_destination
      if substr
        substr.to_s.match(/me/i) ? seeker.im : "##{target}"
      else
        source
      end
    end
  end
end
