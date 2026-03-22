class AddLastSubsidyAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :last_subsidy_at, :datetime
  end
end
