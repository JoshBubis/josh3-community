module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def recalculate_score!
    points = votes.sum(:value)
    update!(score: points, hot_score: HotRank.score_for(points, created_at))
  end

  def vote_from(user)
    return if user.nil?

    votes.find_by(user: user)
  end
end
