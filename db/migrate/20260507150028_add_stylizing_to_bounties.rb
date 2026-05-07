class AddStylizingToBounties < ActiveRecord::Migration[7.1]
  def change
    add_column :bounties, :stylizing, :boolean, default: false, null: false
  end
end
