class SlackBot
  module Kickers
    class Loneliness < SlackBot::Kickers::Base
      def perform_checks
        base_checks && is_alone?
      end

      def message
        "Hey @channel, #{lonely_rider.status_nickname} is alone in Huyguys! Just look at his lonely face and join https://#{ENV["DOMAIN"]}/walls/#{ENV["SLACK_WALL_ID"]}! #{lonely_rider.last_image.imgx_url}"
      end

      private

      def active_riders
        Wall.slack_wall.users.active_in_the_last(15.minutes)
      end

      def lonely_rider
        @lonely_rider ||= active_riders.first
      end

      def is_alone?
        active_riders.size == 1
      end
    end
  end
end
