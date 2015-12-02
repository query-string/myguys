class SlackBot
  module Kickers
    class Base
      attr_reader :time_zone, :work_days, :work_starts, :work_ends

      def initialize
        # @TODO: Extract to .env
        @time_zone   = "Melbourne"
        @work_days   = %w(1 2 3 4 0)
        @work_starts = ActiveSupport::TimeZone[time_zone].parse("09:00")
        @work_ends   = ActiveSupport::TimeZone[time_zone].parse("20:00")
      end

      def perform
        send_message if checks_successful?
      end

      def checks_successful?
        perform_checks
      end

      def send_message
        SlackPost.execute "#general", message
      end

      def message
        "#{local_time.strftime("%H:%M")} is :coffee: o'clock in #{time_zone}!"
      end

      private

      def perform_checks
        # @TODO: Check if anybody is active in Slack
        within_schedule?
      end

      def within_schedule?
        is_work_day? && is_work_time?
      end

      def local_time
        Time.now.in_time_zone(time_zone)
      end

      def is_work_day?
        work_days.include?(local_time.wday.to_s)
      end

      def is_work_time?
        local_time >= work_starts && local_time <= work_ends
      end
    end
  end
end
