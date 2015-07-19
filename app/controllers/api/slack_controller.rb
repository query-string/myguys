module Api
  class SlackController < BaseController
    def create
      image_url    = Image.find(params[:image_id]).imgx_url
      slack_client = Slack::Notifier.new ENV["WEBHOOK_URL"]
      slack_client.ping image_url

      respond_with_success code: "OK"
    end
  end
end
