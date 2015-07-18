module Api
  class SlackController < BaseController
    def create
      Image.find(params[:image_id]).imgx_url
      respond_with_success code: "OK"
    end
  end
end
