class RepairsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_technicien

  def scan
    # Page avec le scanner QR
  end

  def show
    @repair = Repair.find_by!(qr_token: params[:qr_token])
    @already_repaired = @repair.repaired_by?(current_user)
  end

  def validate_code
    @repair = Repair.find_by!(qr_token: params[:qr_token])

    if @repair.repaired_by?(current_user)
      render json: { success: false, error: "Vous avez deja repare cet objet." }, status: :unprocessable_entity
      return
    end

    if params[:code].strip.downcase == @repair.code.strip.downcase
      ActiveRecord::Base.transaction do
        @repair.mark_repaired!(current_user)

        # Crediter 40 credits
        current_user.update!(credits: current_user.credits + @repair.reward_credits)
        current_user.broadcast_credits_update

        # Envoyer un holonews de GERVATEX
        sender = User.joins(:group).where(groups: { name: "PNJ" }).first
        if sender
          Holonew.create!(
            title: "Confirmation de service - GERVATEX",
            content: "Agent #{current_user.username.titleize}, nous accusons reception de la reparation de l'equipement \"#{@repair.name}\". Le conglomerat GERVATEX est satisfait de vos services. Une prime de #{@repair.reward_credits} credits a ete creditee sur votre compte. Continuez votre excellent travail.",
            sender: sender,
            sender_alias: "GERVATEX Corp.",
            target_user: current_user.id
          )
        end
      end

      render json: { success: true, message: "Reparation validee ! #{@repair.reward_credits} credits credites." }
    else
      render json: { success: false, error: "Code incorrect. Verifiez les pieces reunies." }, status: :unprocessable_entity
    end
  end

  private

  def require_technicien
    unless current_user.username == "Agent B-47"
      redirect_to root_path, alert: "Seuls les Techniciens peuvent acceder aux reparations."
    end
  end
end
