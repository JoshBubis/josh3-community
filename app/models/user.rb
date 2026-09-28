class User < ApplicationRecord
  has_secure_password

  has_one_attached :avatar
  has_many :api_tokens, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :reports, dependent: :destroy

  attr_accessor :accepted_terms

  normalizes :email, with: ->(value) { value.strip.downcase }
  normalizes :username, with: ->(value) { value.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]{3,20}\z/, message: "must be 3–20 letters, numbers, or underscores" }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :bio, length: { maximum: 500 }
  validates :accepted_terms, acceptance: true, on: :create
  validate :avatar_is_reasonable

  def avatar_is_reasonable
    return unless avatar.attached?
    return unless avatar.blob.persisted? || avatar.attachment&.new_record?

    unless avatar.blob.content_type.in?(%w[image/png image/jpeg image/gif image/webp])
      errors.add(:avatar, "must be a PNG, JPEG, GIF, or WebP")
    end
    errors.add(:avatar, "must be under 2 MB") if avatar.blob.byte_size > 2.megabytes
  end
end
