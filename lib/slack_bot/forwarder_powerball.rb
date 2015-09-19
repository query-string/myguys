class SlackBot
  class Forwarder
    module Powerball
      POWERBALL_KEYS = %i(flag message)

      def sender_user_name
        sender.name
      end

      def powerball(attr)
        response = if message.present?
          mentioned_user_ids.any? ? [:users, mentioned_users_with_references] : [:notice, powerball_notice_empty]
        else
          [:notice, powerball_notice_nousers]
        end
        Hash[POWERBALL_KEYS.zip(response)][attr]
      end

      def powerball_notice_empty
        "How can I serve you, my dear @#{sender_user_name}?"
      end

      def powerball_notice_nousers
        "Sorry @#{sender_user_name}, your request must contain at least one *@username*"
      end
    end
  end
end
