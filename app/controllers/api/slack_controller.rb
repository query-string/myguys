module Api
  class SlackController < BaseController
    def create
      image_url    = Image.find(params[:image_id]).imgx_url
      slack_client = Slack::Notifier.new ENV["WEBHOOK_URL"], username: "spyguys"

      slack_client.ping DateTime.now.in_time_zone.to_s,
        icon_emoji: ":ghost:",
        attachments: [
          image_url:   image_url,
          author_name: "@alex",
          author_icon: "https://brandfolder.com/api/favicon/icon?size=18&domain=www.slack.com",
          title:       "User status text",
          color:       "#439FE0"
        ]

      respond_with_success code: "OK"
    end
  end
end
