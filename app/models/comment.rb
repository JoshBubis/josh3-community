class Comment < ApplicationRecord
  include Votable

  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent
  has_many :reports, as: :reportable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 10_000 }
  validate :parent_on_same_post

  before_validation :assign_initial_hot_score, on: :create

  private

  def parent_on_same_post
    return if parent.nil?
    return if parent.post_id == post_id

    errors.add(:parent, "must be on the same post")
  end

  def assign_initial_hot_score
    self.hot_score = HotRank.score_for(score.to_i, created_at || Time.current)
  end
end
