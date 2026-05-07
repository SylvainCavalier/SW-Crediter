class BountiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_wantedex_access
  before_action :require_wantedex_management, only: [:create, :edit, :update, :destroy]
  before_action :require_chasseur, only: [:track, :eliminate]

  def index
    @bounties = Bounty.order(created_at: :desc)
    @bounty = Bounty.new
  end

  def create
    @bounty = Bounty.new(bounty_params)
    @bounty.stylizing = true if @bounty.image.attached?

    if @bounty.save
      enqueue_stylization(@bounty) if @bounty.stylizing?
      redirect_to wantedex_path, notice: "Prime publiee."
    else
      @bounties = Bounty.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @bounty = Bounty.find(params[:id])
  end

  def update
    @bounty = Bounty.find(params[:id])
    new_image_uploaded = bounty_params[:image].present?

    if @bounty.update(bounty_params)
      if new_image_uploaded
        @bounty.update_columns(stylizing: true)
        enqueue_stylization(@bounty)
      end
      @bounty.broadcast_card_update
      redirect_to wantedex_path, notice: "Prime mise a jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bounty = Bounty.find(params[:id])
    @bounty.destroy
    redirect_to wantedex_path, notice: "Prime supprimee."
  end

  def track
    bounty = Bounty.find(params[:id])
    bounty.toggle_tracked!
    redirect_to wantedex_path
  end

  def eliminate
    bounty = Bounty.find(params[:id])
    bounty.toggle_eliminated!
    redirect_to wantedex_path
  end

  private

  def require_chasseur
    return if current_user.character_class == "Chasseur"

    redirect_to wantedex_path, alert: "Reserve aux chasseurs de primes."
  end

  def enqueue_stylization(bounty)
    bounty_id = bounty.id
    Thread.new do
      Rails.application.executor.wrap do
        target = Bounty.find_by(id: bounty_id)
        BountyImageStylizer.call(target) if target
      end
    rescue => e
      Rails.logger.error("[BountiesController] stylization thread crashed: #{e.class}: #{e.message}")
    end
  end

  def bounty_params
    params.require(:bounty).permit(:name, :description, :crime, :reward, :mission_type, :requester, :image)
  end

  def require_wantedex_access
    return if current_user.can_access_wantedex?

    redirect_to root_path, alert: "Vous n'avez pas acces au Wantedex."
  end

  def require_wantedex_management
    return if current_user.can_manage_wantedex?

    redirect_to wantedex_path, alert: "Reserve aux PNJ."
  end
end
