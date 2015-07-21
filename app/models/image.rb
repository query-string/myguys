class Image < ActiveRecord::Base
  belongs_to :user, inverse_of: :images
  validates :user, presence: true
  validates :image_path, presence: true, uniqueness: true

  before_destroy -> { AwsDeletePhoto.execute(image_path) }

  scope :newst, -> { order(created_at: :desc) }

  delegate :status_nickname, :status_message, to: :user, prefix: false

  def imgx_url
    Rails.logger.debug "Please, change the value of a ENV[\"IMGX_URL\"] valriable (it must contain an actual S3 domain name)" if ENV.fetch('IMGX_URL').nil? || ENV.fetch('IMGX_URL') == "XXX"
    imgx_uri = URI.parse(ENV.fetch('IMGX_URL'))
    imgx_uri.path = File.join(imgx_uri.path, image_path)
    imgx_uri.to_s
  end
end

