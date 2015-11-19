class SlackBot
  module Observers
    class Realtime < SlackBot::Observers::Base
      attr_reader :realtime, :client, :data

      def initialize(attributes, &callback)
        @client = attributes.fetch(:realtime).client
        super
      end

      def channel
        data.channel
      end

      def text
        data.text
      end

      def user
        data.user
      end

      private

      def hello_message
        "Realtime listening..."
      end

      def listen
        client.on :message do |data|
          @data = data.to_hashugar
          callback.call type
        end
        client.start
      end

      def type
        realtime.channel_ids.include?(data.channel) ? "public" : "private"
      end
    end
  end
end
