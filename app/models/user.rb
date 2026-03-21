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
  has_one_attached :avatar

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

  # Contacts methods
  def add_contact(contact_username)
    contact_user = User.find_by(username: contact_username)
    return { success: false, error: "Utilisateur introuvable" } unless contact_user

    return { success: false, error: "Vous ne pouvez pas vous ajouter en tant que contact" } if contact_user.id == id

    if contacts.include?(contact_user.id)
      return { success: false, error: "Ce contact existe deja" }
    end

    self.contacts = (contacts || []).push(contact_user.id)
    save ? { success: true, contact: contact_user } : { success: false, error: "Erreur lors de l'ajout du contact" }
  end

  def remove_contact(contact_id)
    self.contacts = (contacts || []).reject { |id| id == contact_id.to_i }
    save ? { success: true } : { success: false, error: "Erreur lors de la suppression du contact" }
  end

  def get_contacts
    return [] if contacts.blank?
    User.where(id: contacts).select(:id, :username)
  end

  def is_contact?(user_id)
    contacts.include?(user_id.to_i) if contacts.present?
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
