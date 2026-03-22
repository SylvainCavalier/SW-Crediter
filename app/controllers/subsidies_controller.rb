class SubsidiesController < ApplicationController
  before_action :authenticate_user!

  COOLDOWN_HOURS = 4

  def new
  end

  def form
    if cooldown_active?
      @remaining_time = remaining_cooldown_time
      render :cooldown and return
    end

    @requested_amount = params[:amount]
  end

  def submit
    if cooldown_active?
      flash[:alert] = "Votre demande précédente est encore en cours de traitement."
      redirect_to new_subsidy_path and return
    end

    unless params[:galactic_oath] == "1"
      flash[:alert] = "Vous devez prêter le Serment Galactique pour finaliser votre demande."
      redirect_to subsidy_form_path and return
    end

    # Le joueur a survécu au formulaire ! Il reçoit 100 crédits
    ActiveRecord::Base.transaction do
      current_user.update!(credits: current_user.credits + 100, last_subsidy_at: Time.current)
      current_user.broadcast_credits_update
    end

    # Envoyer un holonews de la République dans 2 heures
    SendSubsidyHolonewJob.set(wait: 2.hours).perform_later(current_user.id)

    flash[:notice] = "Félicitations, citoyen ! Votre demande de subvention a été approuvée. 100 crédits ont été versés sur votre compte. Vive la République !"
    redirect_to new_transaction_path
  end

  private

  def cooldown_active?
    current_user.last_subsidy_at.present? &&
      current_user.last_subsidy_at > COOLDOWN_HOURS.hours.ago
  end

  def remaining_cooldown_time
    return nil unless current_user.last_subsidy_at.present?
    seconds = ((current_user.last_subsidy_at + COOLDOWN_HOURS.hours) - Time.current).to_i
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    { hours: hours, minutes: minutes }
  end
end
