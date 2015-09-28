class SlackBot
  class Event
    attr_reader :realtime, :callback, :background

    def initialize(attributes)
      @realtime   = attributes.fetch(:realtime)
      @callback   = callback
      @background = false
    end

    def on(&callback)
      @callback = callback

      hello
      thread
    end

    private

    def hello
      lumos hello_message, position: :bottom, delimiter: "❄"
    end

    def thread
      Mutex.new.synchronize do
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
