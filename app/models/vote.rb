class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :value, inclusion: { in: [ -1, 1 ] }
  validates :user_id, uniqueness: { scope: [ :votable_type, :votable_id ] }

  def self.cast!(user:, votable:, direction:)
    value = { "up" => 1, "down" => -1 }[direction.to_s]
    vote = find_or_initialize_by(user: user, votable: votable)

    if direction.to_s == "clear" || value.nil? || (vote.persisted? && vote.value == value)
      vote.destroy! if vote.persisted?
    else
      vote.value = value
      vote.save!
    end

    votable.recalculate_score!
    vote
  end
end
