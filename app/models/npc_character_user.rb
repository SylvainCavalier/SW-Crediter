class NpcCharacterUser < ApplicationRecord
  belongs_to :user
  belongs_to :npc_character

  validates :user_id, uniqueness: { scope: :npc_character_id }
end
