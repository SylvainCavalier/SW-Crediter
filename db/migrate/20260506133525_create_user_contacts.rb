class CreateUserContacts < ActiveRecord::Migration[7.1]
  def up
    create_table :user_contacts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contactable, polymorphic: true, null: false
      t.timestamps
    end
    add_index :user_contacts, [:user_id, :contactable_type, :contactable_id],
              unique: true, name: "index_user_contacts_uniqueness"

    User.reset_column_information
    User.find_each do |user|
      ids = user.read_attribute(:contacts) || []
      ids.each do |contact_id|
        next unless User.exists?(id: contact_id)

        UserContact.find_or_create_by!(
          user_id: user.id,
          contactable_type: "User",
          contactable_id: contact_id
        )
      end
    end

    remove_index :users, :contacts if index_exists?(:users, :contacts, using: :gin)
    remove_column :users, :contacts
  end

  def down
    add_column :users, :contacts, :jsonb, default: [], null: false
    add_index :users, :contacts, using: :gin

    UserContact.where(contactable_type: "User").find_each do |uc|
      user = User.find_by(id: uc.user_id)
      next unless user

      current = user.read_attribute(:contacts) || []
      next if current.include?(uc.contactable_id)

      user.update_column(:contacts, current + [uc.contactable_id])
    end

    drop_table :user_contacts
  end
end
