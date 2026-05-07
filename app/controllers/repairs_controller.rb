class RepairsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_repair_access

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
      gervatex_agent = current_user.character_class == "Technicienne" ||
                       (current_user.pnj? && %w[sylvain noe].include?(current_user.username.downcase))

      ActiveRecord::Base.transaction do
        @repair.mark_repaired!(current_user)

        if gervatex_agent
          current_user.update!(credits: current_user.credits + @repair.reward_credits)
          current_user.broadcast_credits_update

          sender = User.joins(:group).where(groups: { name: "PNJ" }).first
          if sender
            Holonew.create!(
              title: "Confirmation de service - GERVATEX",
              content: "Agent #{current_user.display_username}, nous accusons reception de la reparation de l'equipement \"#{@repair.name}\". Le conglomerat GERVATEX est satisfait de vos services. Une prime de #{@repair.reward_credits} credits a ete creditee sur votre compte. Continuez votre excellent travail.",
              sender: sender,
              sender_alias: "GERVATEX Corp.",
              target_user: current_user.id
            )
          end
        end
      end

      message = gervatex_agent ? "Reparation validee ! #{@repair.reward_credits} credits credites." : "Reparation validee !"
      render json: { success: true, message: message }
    else
      render json: { success: false, error: "Code incorrect. Verifiez les pieces reunies." }, status: :unprocessable_entity
    end
  end

  private

  def require_repair_access
    return if current_user.can_access_repairs?

    redirect_to root_path, alert: "Vous n'avez pas accès aux réparations."
  end
end
