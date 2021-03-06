class SlackBot
  module Kickers
    class Base
      attr_reader :realtime, :target, :time_zone, :work_days, :work_starts, :work_ends

      def initialize(realtime_attributes)
        @target      = realtime_attributes.fetch(:target)
        @realtime    = realtime_attributes.fetch(:realtime)
        @time_zone   = ENV["TIME_ZONE"]
        @work_days   = ENV["WORK_DAYS"].split
        @work_starts = ActiveSupport::TimeZone[time_zone].parse(ENV["WORK_STARTS"])
        @work_ends   = ActiveSupport::TimeZone[time_zone].parse(ENV["WORK_ENDS"])
      end

      def perform
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
