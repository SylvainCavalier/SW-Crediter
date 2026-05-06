class ForceVisionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_force_vision_access
  before_action :require_force_vision_management, only: [:index, :create, :destroy]

  def scan
  end

  def show
    @force_vision = ForceVision.find_by!(qr_token: params[:qr_token])
  end

  def index
    @force_visions = ForceVision.order(created_at: :desc)
    @force_vision = ForceVision.new
  end

  def create
    @force_vision = ForceVision.new(force_vision_params)

    if @force_vision.save
      redirect_to force_visions_path, notice: "Vision ajoutee."
    else
      @force_visions = ForceVision.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @force_vision = ForceVision.find(params[:id])
    @force_vision.destroy
    redirect_to force_visions_path, notice: "Vision supprimee."
  end

  private

  def force_vision_params
    params.require(:force_vision).permit(:name, :video)
  end

  def require_force_vision_access
    return if current_user.can_access_force_vision?

    redirect_to root_path, alert: "Vous n'avez pas acces a la Vision de la Force."
  end

  def require_force_vision_management
    return if current_user.can_manage_force_vision?

    redirect_to force_visions_scan_path, alert: "Reserve aux Maitres de l'ordre."
  end
end
