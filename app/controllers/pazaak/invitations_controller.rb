module Pazaak
  class InvitationsController < ApplicationController
    before_action :authenticate_user!

    def create
      invitee = User.find(params[:invitee_id])
      stake = params[:stake].to_i.clamp(0, 1_000_000)

      if invitee.id == current_user.id
        redirect_to pazaak_lobbies_path, alert: "Vous ne pouvez pas vous inviter vous-même." and return
      end
      if current_user.credits.to_i < stake
        redirect_to pazaak_lobbies_path, alert: "Crédits insuffisants pour cette mise." and return
      end

      invitation = nil
      error = nil

      with_pair_lock(current_user.id, invitee.id) do
        if pair_in_game?(current_user.id, invitee.id)
          error = "Un des deux joueurs est déjà en partie."
          next
        end
        if pending_for_user?(current_user.id) || pending_for_user?(invitee.id)
          error = "Une invitation est déjà en attente pour l'un des deux joueurs."
          next
        end
        invitation = PazaakInvitation.create!(inviter: current_user, invitee: invitee, stake: stake)
      end

      if error
        redirect_to pazaak_lobbies_path, alert: error and return
      end

      respond_to do |format|
        format.turbo_stream do
          Turbo::StreamsChannel.broadcast_replace_to(
            "user_#{invitee.id}",
            target: "pazaak_redirect",
            partial: "pazaak/invitations/invite_modal",
            locals: { invitation: invitation, inviter: current_user }
          )
        end
        format.html { redirect_to pazaak_lobbies_path, notice: "Invitation envoyée." }
      end
    end

    def update
      invitation = PazaakInvitation.find(params[:id])

      case params[:decision]
      when "accept", "decline"
        unless invitation.invitee_id == current_user.id
          redirect_to pazaak_lobbies_path, alert: "Non autorisé." and return
        end
        params[:decision] == "accept" ? accept_invitation(invitation) : decline_invitation(invitation)
      when "cancel"
        unless invitation.inviter_id == current_user.id
          redirect_to pazaak_lobbies_path, alert: "Non autorisé." and return
        end
        cancel_invitation(invitation)
      else
        redirect_to pazaak_lobbies_path, alert: "Action inconnue."
      end
    end

    private

    def accept_invitation(invitation)
      game = nil
      error = nil

      with_pair_lock(invitation.inviter_id, invitation.invitee_id) do
        invitation.reload

        unless invitation.pending?
          error = "Cette invitation n'est plus disponible."
          next
        end
        if invitation.invitee.credits.to_i < invitation.stake.to_i
          error = "Vous n'avez pas assez de crédits pour cette mise."
          next
        end
        if invitation.inviter.credits.to_i < invitation.stake.to_i
          error = "L'invitant n'a plus assez de crédits pour cette mise."
          next
        end
        if pair_in_game?(invitation.inviter_id, invitation.invitee_id)
          error = "Un des deux joueurs est déjà en partie."
          next
        end

        invitation.update!(status: :accepted)
        game = PazaakGame.create!(host: invitation.inviter, guest: invitation.invitee, status: :waiting)
        game.start_game!
        invitation.update!(pazaak_game: game)

        # Expirer toute autre invitation en attente impliquant l'un des deux joueurs
        PazaakInvitation.pending
          .where("inviter_id IN (:ids) OR invitee_id IN (:ids)", ids: [invitation.inviter_id, invitation.invitee_id])
          .where.not(id: invitation.id)
          .update_all(status: PazaakInvitation.statuses[:expired])
      end

      if error
        redirect_to pazaak_lobbies_path, alert: error and return
      end

      Turbo::StreamsChannel.broadcast_replace_to(
        "user_#{invitation.inviter_id}",
        target: "pazaak_redirect",
        partial: "pazaak/redirect",
        locals: { url: pazaak_game_path(game) }
      )
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "pazaak_redirect",
            partial: "pazaak/redirect",
            locals: { url: pazaak_game_path(game) }
          )
        end
        format.html { redirect_to pazaak_game_path(game) }
      end
    end

    def decline_invitation(invitation)
      ActiveRecord::Base.transaction do
        invitation.lock!
        invitation.update!(status: :declined) if invitation.pending?
      end
      redirect_to pazaak_lobbies_path, alert: "Invitation refusée."
    end

    def cancel_invitation(invitation)
      cancelled = false
      ActiveRecord::Base.transaction do
        invitation.lock!
        if invitation.pending?
          invitation.update!(status: :expired)
          cancelled = true
        end
      end

      if cancelled
        Turbo::StreamsChannel.broadcast_replace_to(
          "user_#{invitation.invitee_id}",
          target: "pazaak_redirect",
          partial: "pazaak/invitations/cleared"
        )
        redirect_to pazaak_lobbies_path, notice: "Invitation annulée."
      else
        redirect_to pazaak_lobbies_path, alert: "Invitation déjà traitée."
      end
    end

    def with_pair_lock(a_id, b_id)
      ActiveRecord::Base.transaction do
        # Verrouille les rows User dans un ordre stable pour éviter les deadlocks.
        # Toute opération de matching impliquant l'un des deux joueurs sera sérialisée.
        User.lock.where(id: [a_id, b_id]).order(:id).load
        yield
      end
    end

    def pair_in_game?(a_id, b_id)
      PazaakGame.active_in_progress
        .where("host_id IN (:ids) OR guest_id IN (:ids)", ids: [a_id, b_id])
        .exists?
    end

    def pending_for_user?(user_id)
      PazaakInvitation.active_pending
        .where("inviter_id = :id OR invitee_id = :id", id: user_id)
        .exists?
    end
  end
end
