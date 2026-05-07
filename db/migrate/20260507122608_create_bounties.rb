class CreateBounties < ActiveRecord::Migration[7.1]
  def change
    create_table :bounties do |t|
      t.string :name, null: false
      t.text :description
      t.text :crime
      t.integer :reward, default: 0, null: false
      t.boolean :dead_or_alive, default: false, null: false

      t.timestamps
    end
  end
end
