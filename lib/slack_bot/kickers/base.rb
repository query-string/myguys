class SlackBot
  module Kickers
    class Base
      attr_reader :realtime, :target, :time_zone, :work_days, :work_starts, :work_ends

      def initialize(realtime_attributes)
        @target      = realtime_attributes.fetch(:target)
        @realtime    = realtime_attributes.fetch(:realtime)
        # @TODO: Extract to .env
        @time_zone   = "Melbourne"
        @work_days   = %w(1 2 3 4)
        @work_starts = ActiveSupport::TimeZone[time_zone].parse("09:00")
        @work_ends   = ActiveSupport::TimeZone[time_zone].parse("18:00")
      end

      def perform
        p "Try checks: #{checks_successful?}"
        p "Target: #{target}"
        p "Message: #{message}"
        send_message if checks_successful?
      end

      def checks_successful?
        perform_checks
      end

      def send_message
        SlackPost.execute "##{target}", message
      end

      def message
        "#{local_time.strftime("%H:%M")} is :coffee: o'clock in #{time_zone}!"
      end

      private

      def perform_checks
        base_checks
      end

      def base_checks
        within_schedule? && present_in_slack?
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

      def present_in_slack?
        realtime.active_users.size > 0
      end
    end
  end
end
