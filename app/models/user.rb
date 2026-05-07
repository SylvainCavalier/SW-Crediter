class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:username]

  belongs_to :group
  has_many :subscriptions, dependent: :destroy
  has_many :user_inventory_objects, dependent: :destroy
  has_many :inventory_objects, through: :user_inventory_objects
  has_one :pazaak_stat, dependent: :destroy
  has_many :sent_holonews, class_name: "Holonew", foreign_key: "user_id", dependent: :destroy
  has_many :received_holonews, class_name: "Holonew", foreign_key: "target_user", primary_key: "id"
  has_many :holonew_reads, dependent: :destroy
  has_many :read_holonews, through: :holonew_reads, source: :holonew
  has_many :npc_character_users, dependent: :destroy
  has_many :npc_characters, through: :npc_character_users
  has_many :user_contacts, dependent: :destroy
  has_many :user_contact_entries,
           class_name: "UserContact",
           as: :contactable,
           dependent: :destroy
  has_one_attached :avatar, service: :cloudinary

  validates :username, presence: true, uniqueness: true

  after_commit :resize_image_if_needed

  # Broadcast credits update pour les transferts
  def broadcast_credits_update
    Rails.logger.debug "Broadcasting credits update for user ##{id} on credits_updates_#{id}"
    broadcast_replace_to(
      "credits_updates_#{id}",
      target: "user_#{id}_credits_frame",
      partial: "pages/credits",
      locals: { user: self }
    )
  end

  # Holonews methods
  def has_read?(holonew)
    holonew_reads.exists?(holonew: holonew)
  end

  def mark_holonews_as_read(holonews)
    holonews.each do |holonew|
      record = holonew_reads.find_or_create_by(holonew: holonew)
      unless record.read?
        record.update(read: true)
        puts "Holonew #{holonew.id} marquee comme lue pour #{self.username}"
      end
    end
  end

  # Contacts methods (polymorphic via UserContact)
  def add_contact(name)
    name = name.to_s.strip
    return { success: false, error: "Nom requis" } if name.blank?

    contactable = User.find_by("LOWER(username) = ?", name.downcase) ||
                  NpcCharacter.find_by("LOWER(name) = ?", name.downcase)
    return { success: false, error: "Utilisateur introuvable" } unless contactable

    if contactable.is_a?(User) && contactable.id == id
      return { success: false, error: "Vous ne pouvez pas vous ajouter en tant que contact" }
    end

    if user_contacts.exists?(contactable: contactable)
      return { success: false, error: "Ce contact existe deja" }
    end

    user_contacts.create!(contactable: contactable)
    { success: true, contact: contactable }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.record.errors.full_messages.join(", ") }
  end

  def remove_contact(contactable_type:, contactable_id:)
    record = user_contacts.find_by(contactable_type: contactable_type, contactable_id: contactable_id)
    return { success: false, error: "Contact introuvable" } unless record

    record.destroy
    { success: true }
  end

  def contacts_list
    user_contacts.includes(:contactable).map(&:contactable).compact
  end

  def is_contact?(contactable)
    return false if contactable.nil?
    user_contacts.exists?(contactable_type: contactable.class.name, contactable_id: contactable.id)
  end

  def pj?
    group&.name == "PJ"
  end

  def pnj?
    group&.name == "PNJ"
  end

  def mj?
    group&.name == "MJ"
  end

  def is_pnj?
    pnj?
  end

  def can_access_repairs?
    return true if %w[Technicienne Prospecteur].include?(character_class)
    return true if pnj? && %w[sylvain noe].include?(username.to_s.downcase)

    false
  end

  def can_access_wantedex?
    return true if character_class == "Chasseur"
    return true if can_manage_wantedex?

    false
  end

  def can_manage_wantedex?
    pnj? || mj?
  end

  def can_access_force_vision?
    return true if ["Maître Jedi", "Padawan"].include?(character_class)
    return true if can_manage_force_vision?

    false
  end

  def can_manage_force_vision?
    pnj? && %w[sylvain pia].include?(username.to_s.downcase)
  end

  def self.pnj_contacts
    joins(:group).where(groups: { name: "PNJ" })
  end

  # Username formate pour l'affichage (capitalise via titleize)
  def display_username
    username.presence&.titleize
  end

  # Display name: real first name for PNJ when seen by another PNJ/MJ; fallback to display_username.
  def display_name_for(viewer = nil)
    if pnj? && viewer && (viewer.pnj? || viewer.mj?) && real_first_name.present?
      real_first_name
    else
      display_username
    end
  end

  def name
    username
  end

  private

  def resize_image_if_needed
    return unless saved_change_to_avatar?

    begin
      processed_variant = avatar.variant(resize_to_limit: [800, 800])
      processed_variant.processed
    rescue => e
      Rails.logger.error "Erreur lors du redimensionnement de l'image : #{e.message}"
    end
  end

  def saved_change_to_avatar?
    saved_change_to_attribute?(:avatar) && avatar.attached?
  end
end
