class SlackBot
  # Parses text
  # Calculates destination
  # Returns users
  class Forwarder
    # sender_user     - a real (most likely) person, WHO sends the message
    # channel_users   - a list of channel users brought by rtm.start response
    # mentioned_users - an array of users mentioned in message
    include SlackBot::Environment
    attr_reader :attributes, :realtime, :realtime_message, :target, :text, :source

    def initialize(attributes)
      @attributes       = attributes

      @realtime         = attributes.fetch(:realtime)
      @realtime_message = attributes.fetch(:realtime_message)
      @text             = attributes.fetch(:text)
      @source           = attributes.fetch(:source)
    end
  end
end
