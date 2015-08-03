module Api
  class SlackController < BaseController
    def create
      image = Image.find(params[:image_id])
      SlackPostPhoto.execute "#general", image

      respond_with_success code: "OK"
    end
  end
end
