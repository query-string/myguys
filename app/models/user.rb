class User < ActiveRecord::Base

  has_many :images, dependent: :destroy, inverse_of: :user
  belongs_to :last_image, class_name: 'Image'
  belongs_to :wall, inverse_of: :users

  scope :by_id, -> { order(id: :asc) }
  scope :without_images, -> { where(last_image: nil) }
  scope :active_in_the_last, -> (seconds) {
    joins(:last_image).where(images: { created_at: (seconds.ago..Time.now) })
  }
  scope :inactive_in_the_last, -> (seconds) {
    joins(:last_image).where("images.created_at < ?", seconds.ago)
  }
  scope :with_nickname, -> (nickname) { where("status_nickname = ?", "@#{nickname}") }
  scope :by_the_latest_photo, -> {
    joins(:last_image).order(created_at: :desc)
  }

  validates :secret_token, presence: true, uniqueness: true

  before_save :signify_nickname

  def signify_nickname
    self.status_nickname = "@#{status_nickname}" if status_nickname.present? && status_nickname.chr != "@"
  end
end

