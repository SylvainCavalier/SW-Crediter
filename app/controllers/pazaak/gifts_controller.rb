module Pazaak
  class GiftsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_pnj!

    def new
      @cards = InventoryObject.where(category: "pazaak").order(:price, :name)
      @pjs = User.joins(:group).where(groups: { name: "PJ" }).order(:username)
    end

    def create
      card = InventoryObject.where(category: "pazaak").find_by(id: params[:inventory_object_id])
      recipient = User.joins(:group).where(groups: { name: "PJ" }).find_by(id: params[:recipient_id])

      if card.nil? || recipient.nil?
        redirect_to new_pazaak_gift_path, alert: "Carte ou destinataire invalide." and return
      end

      uio = recipient.user_inventory_objects.find_or_initialize_by(inventory_object: card)
      uio.quantity = uio.quantity.to_i + 1
      uio.save!

      redirect_to pazaak_menu_path, notice: "Carte #{card.name} donnée à #{recipient.display_username}."
    end

    private

    def require_pnj!
      return if current_user&.pnj?

      redirect_to pazaak_menu_path, alert: "Réservé aux PNJ."
    end
  end
end
