class Bounty < ApplicationRecord
  has_one_attached :image, service: :cloudinary

  validates :name, presence: true
  validates :reward, numericality: { greater_than_or_equal_to: 0 }

  def status_label
    dead_or_alive? ? "MORT OU VIF" : "EN VIE UNIQUEMENT"
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
