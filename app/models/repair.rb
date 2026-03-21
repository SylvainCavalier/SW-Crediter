class Repair < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true
  validates :qr_token, presence: true, uniqueness: true

  before_validation :generate_qr_token, on: :create

  def repaired_by?(user)
    repaired_by.include?(user.id)
  end

  def mark_repaired!(user)
    return false if repaired_by?(user)

    self.repaired_by = repaired_by + [user.id]
    save!
  end

  private

  def generate_qr_token
    self.qr_token ||= SecureRandom.hex(8)
  end
end
