class AddStatesToBounties < ActiveRecord::Migration[7.1]
  def change
    add_column :bounties, :tracked, :boolean, default: false, null: false
    add_column :bounties, :eliminated, :boolean, default: false, null: false
  end
end
