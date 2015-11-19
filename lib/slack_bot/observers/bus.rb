class SlackBot
  module Observers
    class Bus < SlackBot::Observers::Base
      attr_reader :conn

      RESTART = "pg_restart"

      private

      def listen
        @conn = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        begin
          conn.async_exec "LISTEN #{RESTART}"
          conn.async_exec "LISTEN #{command_channel}"
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
              callback.call payload
              throw :break_loop if channel == RESTART
            end
          end
        end
      end
    end
  end
end
