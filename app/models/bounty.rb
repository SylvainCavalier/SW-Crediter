class Bounty < ApplicationRecord
  has_one_attached :image, service: :cloudinary

  validates :name, presence: true
  validates :reward, numericality: { greater_than_or_equal_to: 0 }

  def status_label
    dead_or_alive? ? "MORT OU VIF" : "EN VIE UNIQUEMENT"
  end
end
