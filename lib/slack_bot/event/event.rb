class SlackBot
  class Event
    attr_reader :realtime, :mutex, :bgthread

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      @mutex    = Mutex.new
      @bgthread = false

      hello
      start
    end

    def hello
      lumos hello_message, position: :bottom, delimiter: "❄"
    end

    def start
      mutex.synchronize do
        unless bgthread
          bgthread = true
          Thread.new do
            connection
            bgthread = false
          end
        end
      end
    end
  end
end
