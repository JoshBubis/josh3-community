class Post < ApplicationRecord
  include Votable

  belongs_to :user
  belongs_to :channel
  has_many :comments, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  validates :title, presence: true, length: { maximum: 300 }
  validates :body, length: { maximum: 20_000 }
  validates :link_url, format: { with: %r{\Ahttps?://[^\s]+\z}i, message: "must be an http or https URL" }, allow_blank: true
  validate :body_or_link

  before_validation :assign_initial_hot_score, on: :create

  scope :visible, -> { where(removed: false) }
  scope :hot, -> { order(hot_score: :desc, created_at: :desc) }
  scope :newest, -> { order(created_at: :desc) }

  def self.ranked(sort)
    sort.to_s == "new" ? newest : hot
  end

  def link_post?
    link_url.present?
  end

  private

  def body_or_link
    return if body.present? || link_url.present?

    errors.add(:base, "Add some text or a link.")
  end

  def assign_initial_hot_score
    self.hot_score = HotRank.score_for(score.to_i, created_at || Time.current)
  end
end
