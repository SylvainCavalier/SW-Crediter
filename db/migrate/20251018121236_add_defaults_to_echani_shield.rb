class AddDefaultsToEchaniShield < ActiveRecord::Migration[7.1]
  def change
    # D'abord, corriger les valeurs NULL existantes
    User.update_all("echani_shield_current = 0 WHERE echani_shield_current IS NULL")
    User.update_all("echani_shield_max = 0 WHERE echani_shield_max IS NULL")
    
    # Puis ajouter les défauts pour les futures colonnes
    change_column_default :users, :echani_shield_current, 0
    change_column_default :users, :echani_shield_max, 0
    
    # Optionnel : ajouter NOT NULL si désiré
    # change_column_null :users, :echani_shield_current, false, 0
    # change_column_null :users, :echani_shield_max, false, 0
  end
end
