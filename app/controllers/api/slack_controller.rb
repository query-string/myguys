module Api
  class SlackController < BaseController
    COMMANDS_ALLOWED = %w(help show)
    COMMANDS_HELP    = [
      "`/higuys show us @username` – shows the latest user photo in public channel",
      "`/higuys show me @username` – sends the latest user photo to PM"
    ]

    def create
      image = Image.find(params[:image_id])
      SlackPostPhoto.execute "#general", image

      respond_with_success code: "OK"
    end

    def slash_command
      message = if params[:token].present? && COMMANDS_ALLOWED.find { |e| /#{e}/ =~ params[:text] }
        if params[:text] == "help"
          COMMANDS_HELP.join("\n")
        else
          SlackBot::Notifier.new("slash_notification", {
            text:       params[:text],
            user_name:  params[:user_name],
            user_id:    params[:user_id],
            channel:    params[:channel_name],
            channel_id: params[:channel_id]
          }).notify
          ":ok_hand: Processing..."
        end
      else
        ":thinking_face: Sorry, but this command is not allowed. Could you check `/higuys help` first?"
      end

      render text: message
    end
  end
end
