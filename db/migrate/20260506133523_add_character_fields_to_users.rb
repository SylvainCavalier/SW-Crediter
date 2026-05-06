class AddCharacterFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :character_class, :string
    add_column :users, :real_first_name, :string
    add_column :users, :character_name_chosen, :boolean, default: false, null: false
  end
end
