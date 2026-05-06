class CreateNpcCharacters < ActiveRecord::Migration[7.1]
  def change
    create_table :npc_characters do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :npc_characters, "LOWER(name)", unique: true, name: "index_npc_characters_on_lower_name"

    create_table :npc_character_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :npc_character, null: false, foreign_key: true
      t.timestamps
    end
    add_index :npc_character_users, [:user_id, :npc_character_id], unique: true, name: "index_npc_char_users_on_user_and_npc"
  end
end
