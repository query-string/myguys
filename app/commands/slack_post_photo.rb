class SlackPostPhoto < Struct.new(:image)
  extend Command
  attr_reader :image

  def initialize(image)
    @image       = image
    @attachments = default_attachments
    extend_attachments
  end

  def execute
    SlackPost.execute(
      "*The latest available photo* – #{Time.zone.at(image.created_at).strftime("%d %B %Y at %T")}",
      @attachments
    )
  end

  def default_attachments
    {
      image_url:   image.imgx_url,
      author_icon: "https://brandfolder.com/api/favicon/icon?size=18&domain=www.slack.com"
    }
  end

  private

  def extend_attachments
    add_attachment_nickname
    add_attachment_status
  end

  def add_attachment_nickname
   @attachments.merge!(author_name: image.status_nickname) if image.status_nickname.present?
  end

  def add_attachment_status
    @attachments.merge!(text: image.status_message) if image.status_message.present?
  end
end
