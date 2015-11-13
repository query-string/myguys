class SlackBot
  class ResponderUsers
    attr_reader :realtime, :message

    def initialize(attributes)
      @realtime = attributes.fetch(:realtime)
      @message  = attributes.fetch(:message)
    end

    def mentioned
      mentioned_ids.map do |user|
        team_user = realtime.team_user_by_id user
        team_user ? team_user.name : user
      end
    end

    def mentioned_ids
      message.scan(realtime.regex).flatten
    end

    def with_references
      mentioned.map do |slack_user|
        local_user = User.with_nickname(slack_user).by_the_latest_photo.first
        local_user ? {found_in: :local, user: local_user} : {found_in: :slack, user: slack_user}
      end
    end

    def in_slack
      with_references.select { |user| user[:found_in] == :slack }
    end

    def in_local
      with_references.select { |user| user[:found_in] == :local }.map { |user| user[:user] }
    end

    def local_names
      in_local.map { |local| local[:status_nickname].gsub("@", "") }
    end

    def local_diff
      mentioned - local_names
    end
  end
 end
