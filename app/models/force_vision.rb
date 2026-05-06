class ForceVision < ApplicationRecord
  has_one_attached :video, service: :ovh

  validates :name, presence: true
  validates :qr_token, presence: true, uniqueness: true
  validate :video_must_be_attached

  before_validation :generate_qr_token, on: :create

  private

  def generate_qr_token
    self.qr_token ||= SecureRandom.hex(8)
  end

  def video_must_be_attached
    errors.add(:video, "doit etre fournie") unless video.attached?
  end
end
