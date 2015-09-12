module Api
  class SlackController < BaseController
    def create
      image = Image.find(params[:image_id])
      SlackPostPhoto.execute "#general", image

      respond_with_success code: "OK"
    end

    def slash_command
      payload = {
        channel_id:   params[:channel_id],
        channel_name: params[:channel_name],
        user_id:      params[:user_id],
        user_name:    params[:user_name],
        text:         params[:text]
      }
      ActiveRecord::Base.connection.execute %Q(NOTIFY "slack_bot", '#{payload}') if params[:token].present?

      render :none
    end
  end
end
