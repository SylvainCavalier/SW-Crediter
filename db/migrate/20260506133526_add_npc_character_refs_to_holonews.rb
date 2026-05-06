class AddNpcCharacterRefsToHolonews < ActiveRecord::Migration[7.1]
  def change
    add_reference :holonews, :target_npc_character, foreign_key: { to_table: :npc_characters }
    add_reference :holonews, :sender_npc_character, foreign_key: { to_table: :npc_characters }
  end
end
