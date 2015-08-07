class SlackPost < Struct.new(:channel, :text, :attachments)
  extend Command

  def execute
    Slack.chat_postMessage(
      as_user:     true,
      username:    "higuys",
      channel:     channel,
      text:        text,
      icon_emoji:  ":ghost:",
      attachments: [extended_attachments]
    )
  end

  private

  def defaults
    {color: "#439FE0"}
  end

  def extended_attachments
    attachments.nil? ? defaults : attachments.merge(defaults)
  end
end
