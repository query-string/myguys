class SlackBot
  class BusObserver < Observer
    attr_reader :conn

    CHANNEL = "slack_bot"
    RESTART = "pg_restart"

    private

    def hello_message
      "Listening PG..."
    end

    def listen
      @conn = ActiveRecord::Base.connection.instance_variable_get(:@connection)
      begin
        conn.async_exec "LISTEN #{RESTART}"
        conn.async_exec "LISTEN #{CHANNEL}"
        execute
      rescue => error
        p [:error, error]
      ensure
        conn.async_exec "UNLISTEN *"
      end
    end

    def execute
      catch(:break_loop) do
        loop do
          conn.wait_for_notify do |channel, pid, payload|
            callback.call
            throw :break_loop if channel == RESTART
          end
        end
      end
    end
  end
end
