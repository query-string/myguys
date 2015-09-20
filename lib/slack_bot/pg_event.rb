class SlackBot
  class PgEvent
    attr_reader :realtime

    CHANNEL       = "slack_bot"
    RESET_CHANNEL = "pg_restart"

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      on
    end

    def on
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
