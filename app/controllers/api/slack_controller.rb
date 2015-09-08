module Api
  class SlackController < BaseController
    include Wisper::Publisher

    def create
      image = Image.find(params[:image_id])
      SlackPostPhoto.execute "#general", image

      respond_with_success code: "OK"
    end

    def slash_command
      publish(:command_fired, params)

      render({text: "Ololo!"})
    end
  end
end
