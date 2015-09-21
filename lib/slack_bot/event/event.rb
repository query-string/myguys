class SlackBot
  class Event
    attr_reader :realtime, :callback, :mutex, :background

    def initialize(attributes, &callback)
      @realtime   = attributes.fetch(:realtime)
      @callback   = callback
      @mutex      = Mutex.new
      @background = false

      hello
      thread
    end

    private

    def hello
      lumos hello_message, position: :bottom, delimiter: "❄"
    end

    def thread
      mutex.synchronize do
        unless background
          background = true
          Thread.new do
            listen
            background = false
          end
        end
      end
    end
  end
end
