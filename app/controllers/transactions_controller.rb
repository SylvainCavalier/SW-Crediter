class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transfer_users, only: [:new, :create]

  def create
    receiver = resolve_receiver(params[:transaction][:receiver_username])

    if receiver.nil?
      flash.now[:alert] = 'Destinataire introuvable'
      render :new, status: :unprocessable_entity and return
    end

    if receiver == current_user
      flash.now[:alert] = 'Vous ne pouvez pas vous envoyer des crédits à vous-même.'
      render :new, status: :unprocessable_entity and return
    end

    unless current_user.is_contact?(receiver) || receiver.is_pnj?
      flash.now[:alert] = 'Vous ne pouvez transférer des crédits qu\'à vos contacts.'
      render :new, status: :unprocessable_entity and return
    end

    @transaction = Transaction.new(transaction_params)
    @transaction.sender = current_user
    @transaction.receiver = receiver

    if @transaction.amount <= current_user.credits && @transaction.amount > 0
      ActiveRecord::Base.transaction do
        current_user.update!(credits: current_user.credits - @transaction.amount)
        receiver.update!(credits: receiver.credits + @transaction.amount)
        @transaction.save!

        current_user.broadcast_credits_update
        receiver.broadcast_credits_update
      end

      flash[:notice] = 'Transfert réussi.'
      redirect_to new_transaction_path
    else
      flash.now[:alert] = 'Transfert échoué, crédits insuffisants.'
      render :new, status: :unprocessable_entity
    end
  rescue => e
    flash.now[:alert] = "Une erreur s'est produite : #{e.message}"
    render :new, status: :internal_server_error
  end

  def new
    @transaction = Transaction.new
  end

  private

  def transaction_params
    params.require(:transaction).permit(:amount, :receiver_username)
  end

  # Receiver can be matched by username (PJ/PNJ direct account) or by NpcCharacter name
  # (in which case credits go to the first user incarnating that character).
  def resolve_receiver(name)
    return nil if name.blank?
    name = name.strip

    user = User.where('LOWER(username) = ?', name.downcase).first
    return user if user

    npc = NpcCharacter.where('LOWER(name) = ?', name.downcase).first
    npc&.users&.first
  end

  def set_transfer_users
    @contacts = current_user.contacts_list
    @pnj_users = User.pnj_contacts
                     .where.not(id: current_user.id)
                     .includes(avatar_attachment: :blob)
                     .order(:username)
    @npc_characters = NpcCharacter.order(:name)
    @transfer_users = @contacts + @pnj_users
  end
end
