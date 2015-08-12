json.array! @users do |user|
  json.id user.id
  json.status_message user.status_message
  json.status_nickname user.status_nickname
  json.image_id user.last_image.id
  json.image_url user.last_image.try(:imgx_url)
  json.active_at user.last_image.try(:created_at)
  json.is_slackable ENV["SLACK_BOT_TOKEN"].present?
end
