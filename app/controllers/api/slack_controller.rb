module Api
  class SlackController < BaseController
    def create
      image = Image.find(params[:image_id])
      SlackPostPhoto.execute "#general", image

      respond_with_success code: "OK"
    end

    def slash_command
      # @TODO: Validate message, post it as DM to bot, clean it up
      p params
      render({text: "Processing..."})
    end
  end
end
