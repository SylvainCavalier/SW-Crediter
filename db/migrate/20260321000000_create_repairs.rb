class CreateRepairs < ActiveRecord::Migration[7.1]
  def change
    create_table :repairs do |t|
      t.string :name, null: false
      t.text :description
      t.jsonb :required_parts, default: [], null: false
      t.string :code, null: false
      t.string :qr_token, null: false
      t.jsonb :repaired_by, default: [], null: false
      t.integer :reward_credits, default: 40, null: false

      t.timestamps
    end

    add_index :repairs, :qr_token, unique: true
  end
end
