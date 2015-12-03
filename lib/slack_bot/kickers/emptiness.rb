class SlackBot
  module Kickers
    class Emptiness < SlackBot::Kickers::Base
      def perform_checks
        within_schedule? && empty_for_a_long_time
      end

      def message
        "Hey @channel, I've discovered that nobody has been active in Higuys since #{last_date.strftime("%b #{last_date.day.ordinalize}")}. Why don't ya join?"
      end

      private

      def empty_for_a_long_time
        User.active_in_the_last(12.hours).size == 0
      end

      def last_user
        User.by_the_latest_photo.last
      end

      def last_image
        @last_image ||= last_user.last_image
      end

      def last_date
        last_image.created_at
      end
    end
  end
end
