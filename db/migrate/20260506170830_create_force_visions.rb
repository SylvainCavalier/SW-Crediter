class CreateForceVisions < ActiveRecord::Migration[7.1]
  def change
    create_table :force_visions do |t|
      t.string :name, null: false
      t.string :qr_token, null: false

      t.timestamps
    end
    add_index :force_visions, :qr_token, unique: true
  end
end
