class SlackPost < Struct.new(:text, :attachments)
  extend Command

  def execute
    Slack.chat_postMessage(
      username:    "higuys",
      channel:     "#general",
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
