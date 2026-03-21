class AddSizeAndWeightToPets < ActiveRecord::Migration[7.1]
  def change
    # Ajout des colonnes avec des valeurs par défaut
    add_column :pets, :size, :integer, default: 100, null: false
    add_column :pets, :weight, :integer, default: 50, null: false

    # Data migration removed — pets table will be dropped by cleanup migration
  end
end
