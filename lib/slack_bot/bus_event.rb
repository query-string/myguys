class SlackBot
  class BusEvent
    attr_reader :realtime, :mutex, :bgthread

    CHANNEL       = "slack_bot"
    RESET_CHANNEL = "pg_restart"

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      @mutex    = Mutex.new
      @bgthread = false

      hello
      start
    end

    def hello
      lumos "Listening PG...", position: :bottom, delimiter: "❄"
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

    def connection
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        conn = connection.instance_variable_get(:@connection)
        begin
          conn.async_exec "LISTEN #{RESET_CHANNEL}"
          conn.async_exec "LISTEN #{CHANNEL}"
          catch(:break_loop) do
            loop do
              conn.wait_for_notify do |channel, pid, payload|
                p realtime
                p payload
                throw :break_loop if channel == RESET_CHANNEL
              end
            end
          end
        rescue => error
          p [:error, error]
        ensure
          conn.async_exec "UNLISTEN *"
        end
      end
    end
  end
end
