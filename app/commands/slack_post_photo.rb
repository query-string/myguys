class SlackPostPhoto < Struct.new(:image)
  extend Command

  def execute
    @attachments  = {
      image_url:   image.imgx_url,
      author_icon: "https://brandfolder.com/api/favicon/icon?size=18&domain=www.slack.com",
      color:       "#439FE0"
    }

    add_nickname
    add_status

    Slack.chat_postMessage  username: "higuys",
                            channel: "#general",
                            text: DateTime.now.in_time_zone.to_s,
                            icon_emoji: ":ghost:",
                            attachments: [@attachments]
  end

  private

  def add_nickname
    @attachments.merge!(author_name: image.status_nickname) if image.status_nickname.present?
  end

  def add_status
    @attachments.merge!(text: image.status_message) if image.status_message.present?
  end
end
