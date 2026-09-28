class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  validates :reason, presence: true, length: { minimum: 10, maximum: 2_000 }
  validates :status, inclusion: { in: %w[open closed] }
  validates :user_id, uniqueness: { scope: [ :reportable_type, :reportable_id ] }

  scope :open_reports, -> { where(status: "open").order(created_at: :desc) }
end
