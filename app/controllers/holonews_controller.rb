class HolonewsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.mj?
      @holonews = Holonew.published.includes(:sender).order(created_at: :desc).page(params[:page]).per(10)
    else
      npc_ids = current_user.npc_characters.pluck(:id).presence || [-1]
      @holonews = Holonew.published.includes(:sender)
                          .where("target_user = :uid OR target_npc_character_id IN (:npc_ids) OR target_group IN (:groups)",
                                 uid: current_user.id,
                                 npc_ids: npc_ids,
                                 groups: [current_user.group.name.to_s, 'all'])
                          .order(created_at: :desc)
                          .page(params[:page]).per(10)
    end

    unless params[:page]
      current_user.mark_holonews_as_read(@holonews)
    end

    respond_to do |format|
      format.html
    end
  end

  def new
    @holonew = Holonew.new
    @groups = Group.all

    if params[:reply_to].present?
      original_holonew = Holonew.find(params[:reply_to])
      @holonew.title = "Re: #{original_holonew.title}"
      @reply_to_id = original_holonew.id
      if original_holonew.sender_npc_character_id.present?
        @reply_target = original_holonew.sender_npc_character
        @reply_recipient_value = "npc:#{original_holonew.sender_npc_character_id}"
        @reply_display_label = original_holonew.sender_alias.presence || original_holonew.sender_npc_character.name
      else
        @reply_target = original_holonew.sender
        @reply_recipient_value = "user:#{original_holonew.user_id}"
        @reply_display_label = original_holonew.sender_alias.presence || original_holonew.sender.display_username
      end
    end

    @recipient_options = build_recipient_options
    @sender_npc_options = current_user.npc_characters.order(:name) if current_user.pnj?

    inject_reply_option_if_missing if @reply_recipient_value.present?
  end

  def create
    @holonew = Holonew.new(holonew_params)
    @holonew.sender = current_user
    save_as_draft = current_user.pnj? && params[:save_as_draft].present?
    @holonew.draft = save_as_draft

    target = parse_target(params[:recipient])

    if current_user.pj?
      unless target_allowed_for_pj?(target, params[:reply_to])
        return redirect_to new_holonew_path, alert: "Vous ne pouvez envoyer des messages qu'à vos contacts."
      end
    end

    case target
    when Hash
      if target[:type] == "user"
        @holonew.target_user = target[:id]
      elsif target[:type] == "npc_character"
        npc = NpcCharacter.find_by(id: target[:id])
        if npc
          @holonew.target_npc_character = npc
          @holonew.target_user = npc.users.first&.id
        end
      elsif target[:type] == "group"
        @holonew.target_group = target[:id]
      elsif target[:type] == "all"
        @holonew.target_group = "all"
      end
    end

    if current_user.pnj? && params[:sender_npc_character_id].present?
      npc = current_user.npc_characters.find_by(id: params[:sender_npc_character_id])
      @holonew.sender_npc_character = npc if npc
    end

    if @holonew.save
      notice = save_as_draft ? "Brouillon enregistré" : "Holonew envoyée"
      redirect_path = save_as_draft ? holonews_drafts_path : new_holonew_path
      respond_to do |format|
        format.html { redirect_to redirect_path, notice: notice }
      end
    else
      @recipient_options = build_recipient_options
      @sender_npc_options = current_user.npc_characters.order(:name) if current_user.pnj?
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def drafts
    return redirect_to holonews_path, alert: "Accès réservé aux PNJ." unless current_user.pnj? || current_user.mj?

    @drafts = Holonew.drafts.includes(:sender).order(created_at: :desc)
  end

  def send_draft
    return redirect_to holonews_path, alert: "Accès réservé aux PNJ." unless current_user.pnj? || current_user.mj?

    @holonew = Holonew.drafts.find(params[:id])
    @holonew.update(draft: false, created_at: Time.current)
    @holonew.update_holonews_counter

    redirect_to holonews_drafts_path, notice: "Holonew envoyée"
  end

  private

  def holonew_params
    params.require(:holonew).permit(:title, :content, :image, :sender_alias).merge(user_id: current_user.id)
  end

  # recipient encoded as "user:<id>" / "npc:<id>" / "group:<name>" / "all"
  def parse_target(value)
    return nil if value.blank?

    if value == "all"
      { type: "all" }
    elsif value.start_with?("user:")
      { type: "user", id: value.split(":", 2).last.to_i }
    elsif value.start_with?("npc:")
      { type: "npc_character", id: value.split(":", 2).last.to_i }
    elsif value.start_with?("group:")
      { type: "group", id: value.split(":", 2).last }
    end
  end

  def target_allowed_for_pj?(target, reply_to_id = nil)
    return false if target.nil?
    return true if target[:type] == "all"

    case target[:type]
    when "user"
      user = User.find_by(id: target[:id])
      return false unless user
      current_user.is_contact?(user) || matches_reply_sender?(target, reply_to_id)
    when "npc_character"
      npc = NpcCharacter.find_by(id: target[:id])
      return false unless npc
      current_user.is_contact?(npc) || matches_reply_sender?(target, reply_to_id)
    when "group"
      false
    else
      false
    end
  end

  # When replying to a holonew, allow targeting the original sender even if
  # they aren't in the PJ's contacts (you can answer someone who wrote first).
  def matches_reply_sender?(target, reply_to_id)
    return false if reply_to_id.blank?
    original = Holonew.find_by(id: reply_to_id)
    return false unless original

    if target[:type] == "npc_character"
      original.sender_npc_character_id == target[:id]
    elsif target[:type] == "user"
      original.sender_npc_character_id.blank? && original.user_id == target[:id]
    else
      false
    end
  end

  def inject_reply_option_if_missing
    already_present = @recipient_options.any? do |group|
      group[1].any? { |opt| opt[1] == @reply_recipient_value }
    end
    return if already_present

    @recipient_options.unshift(["Réponse à", [[@reply_display_label, @reply_recipient_value]]])
  end

  # Builds the recipient select options for the new holonew form
  def build_recipient_options
    if current_user.pj?
      contacts_group = current_user.contacts_list.map do |c|
        if c.is_a?(NpcCharacter)
          [c.name, "npc:#{c.id}"]
        else
          [c.display_username, "user:#{c.id}"]
        end
      end
      [
        ["Contacts", contacts_group]
      ]
    else
      users_group = User.order(:username).map { |u| [u.display_username, "user:#{u.id}"] }
      npcs_group = NpcCharacter.order(:name).map { |npc| [npc.name, "npc:#{npc.id}"] }
      [
        ["Joueurs", users_group],
        ["Personnages PNJ", npcs_group]
      ]
    end
  end
end
