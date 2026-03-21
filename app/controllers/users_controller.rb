class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :settings, :update_settings]

  def show
    # Stocker la page d'origine
    if request.referer.present? && !request.referer.include?(user_path(@user))
      session[:return_to] = request.referer
    end

    # Inventaire
    @inventory_items = @user.user_inventory_objects.includes(:inventory_object)
  end

  def settings
    @user = current_user
  end

  def update_settings
    @user = current_user
    redirect_to settings_user_path(@user), notice: 'Réglages mis à jour avec succès.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
