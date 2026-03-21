class AddAttributesToPets < ActiveRecord::Migration[7.1]
  def change
    # Ajouter les colonnes avec leurs valeurs par défaut
    add_column :pets, :mood, :integer, default: 0, null: false
    add_column :pets, :loyalty, :integer, default: 0, null: false
    add_column :pets, :hunger, :integer, default: 0, null: false
    add_column :pets, :fatigue, :integer, default: 0, null: false

    # Ajouter la référence status sans contrainte NOT NULL pour l'instant
    add_reference :pets, :status, foreign_key: true, null: true

    # Data migration removed — pets table will be dropped by cleanup migration
  end
end
