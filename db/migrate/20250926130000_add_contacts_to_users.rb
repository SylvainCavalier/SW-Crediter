class AddContactsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :contacts, :jsonb, default: [], null: false
    add_index :users, :contacts, using: :gin
  end
end
