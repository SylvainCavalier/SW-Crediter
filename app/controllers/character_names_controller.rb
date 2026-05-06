class CharacterNamesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :require_character_name_chosen, only: [:new, :create]

  def new
    redirect_to root_path and return unless current_user.pj?
    redirect_to root_path and return if current_user.character_name_chosen?
  end

  def create
    redirect_to root_path and return unless current_user.pj?
    redirect_to root_path and return if current_user.character_name_chosen?

    chosen_name = params[:character_name].to_s.strip

    if chosen_name.blank?
      flash.now[:alert] = "Tu dois choisir un nom pour ton personnage."
      render :new, status: :unprocessable_entity and return
    end

    if User.where("LOWER(username) = ?", chosen_name.downcase).where.not(id: current_user.id).exists? ||
       NpcCharacter.where("LOWER(name) = ?", chosen_name.downcase).exists?
      flash.now[:alert] = "Ce nom est déjà utilisé. Choisis-en un autre."
      render :new, status: :unprocessable_entity and return
    end

    if current_user.update(username: chosen_name, character_name_chosen: true)
      bypass_sign_in(current_user)
      redirect_to root_path, notice: "Bienvenue, #{chosen_name} !"
    else
      flash.now[:alert] = current_user.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end
end
