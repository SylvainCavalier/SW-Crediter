class UserContact < ApplicationRecord
  belongs_to :user
  belongs_to :contactable, polymorphic: true

  validates :user_id, uniqueness: { scope: [:contactable_type, :contactable_id] }
  validate :cannot_contact_self

  private

  def cannot_contact_self
    return unless contactable_type == "User" && contactable_id == user_id
    errors.add(:base, "Vous ne pouvez pas vous ajouter en tant que contact")
  end
end
