class SlackBot
  module Kickers
    class Emptiness < SlackBot::Kickers::Base
      def perform_checks
        base_checks && empty_for_a_long_time?
      end

      def message
        "Hey @channel, I've discovered that nobody has been active in Higuys since #{last_date.strftime("%b #{last_date.day.ordinalize}")}. Why don't ya join?"
      end

      private

      def empty_for_a_long_time?
        Wall.slack_wall.users.active_in_the_last(12.hours).empty?
      end

      def last_user
        Wall.slack_wall.users.by_the_latest_photo.last
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
