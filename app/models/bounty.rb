class Bounty < ApplicationRecord
  has_one_attached :image, service: :cloudinary

  enum :mission_type, { alive_only: 0, dead_or_alive: 1, locate: 2 }, default: :alive_only

  MISSION_TYPE_LABELS = {
    "alive_only"    => "EN VIE UNIQUEMENT",
    "dead_or_alive" => "MORT OU VIF",
    "locate"        => "LOCALISER"
  }.freeze

  MISSION_TYPE_FORM_OPTIONS = [
    ["En vie uniquement", "alive_only"],
    ["Mort ou vif",       "dead_or_alive"],
    ["Localiser",         "locate"]
  ].freeze

  validates :name, presence: true
  validates :reward, numericality: { greater_than_or_equal_to: 0 }

  def status_label
    MISSION_TYPE_LABELS[mission_type]
  end

  def toggle_tracked!
    transaction do
      if tracked?
        update!(tracked: false)
      else
        # Only one bounty can be the active focus at a time.
        Bounty.where.not(id: id).where(tracked: true).update_all(tracked: false)
        update!(tracked: true, eliminated: false)
        Bounty.where.not(id: id).find_each(&:broadcast_card_update)
      end
    end
    broadcast_card_update
  end

  def toggle_eliminated!
    if eliminated?
      update!(eliminated: false)
    else
      update!(eliminated: true, tracked: false)
    end
    broadcast_card_update
  end

  def broadcast_card_update
    %i[chasseur manager].each do |role|
      broadcast_replace_to(
        "bounties_#{role}",
        target: "bounty_#{id}",
        partial: "bounties/poster",
        locals: { bounty: self, viewer_role: role }
      )
    end
  end
end
