module Api
  class SlackController < BaseController
    def create
      image = Image.find(params[:image_id])
      SlackPostPhoto.execute "#general", image

      respond_with_success code: "OK"
    end

    def slash_command
      if params[:token].present?
        SlackBot::Notifier.new("slack_bot", {
          text:       params[:text],
          user_name:  params[:user_name],
          user_id:    params[:user_id],
          channel:    params[:channel_name],
          channel_id: params[:channel_id]
        }).notify
      end

      render text: ":ok_hand:"
    end
  end
end
