class AddDraftToHolonews < ActiveRecord::Migration[7.1]
  def change
    add_column :holonews, :draft, :boolean, default: false, null: false
    add_index :holonews, :draft
  end
end
