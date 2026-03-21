class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    @user = current_user
    @unread_holonews_count = current_user.holonew_reads.where(read: false).count
  end

  def team
    @players = User.includes(:avatar_attachment)
                   .joins(:group).where(groups: { name: "PJ" })
                   .order(:username)
  end

  def avatar_upload
    @user = User.find(params[:id])
    if @user.update(avatar_params)
      redirect_to root_path, notice: "Avatar mis à jour avec succès !"
    else
      redirect_to root_path, alert: "Erreur lors de l'upload."
    end
  end

  private

  def avatar_params
    params.require(:user).permit(:avatar)
  end
end
