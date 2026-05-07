class AddRequesterAndMissionTypeToBounties < ActiveRecord::Migration[7.1]
  def up
    add_column :bounties, :requester, :string
    add_column :bounties, :mission_type, :integer, default: 0, null: false

    # Backfill from the old boolean: true → dead_or_alive (1), false → alive_only (0)
    execute <<~SQL
      UPDATE bounties
      SET mission_type = CASE WHEN dead_or_alive THEN 1 ELSE 0 END
    SQL

    remove_column :bounties, :dead_or_alive
  end

  def down
    add_column :bounties, :dead_or_alive, :boolean, default: false, null: false
    execute <<~SQL
      UPDATE bounties
      SET dead_or_alive = (mission_type = 1)
    SQL
    remove_column :bounties, :mission_type
    remove_column :bounties, :requester
  end
end
