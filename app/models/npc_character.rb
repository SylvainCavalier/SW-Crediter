class NpcCharacter < ApplicationRecord
  has_many :npc_character_users, dependent: :destroy
  has_many :users, through: :npc_character_users

  has_many :user_contact_entries,
           class_name: "UserContact",
           as: :contactable,
           dependent: :destroy

  has_many :received_holonews,
           class_name: "Holonew",
           foreign_key: "target_npc_character_id",
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def display_name
    name
  end
end
