class ApiToken < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 80 }

  def self.digest(raw)
    Digest::SHA256.hexdigest(raw.to_s)
  end

  def self.authenticate(raw)
    return if raw.blank?

    find_by(token_digest: digest(raw))
  end

  # Returns [record, plaintext]. The plaintext is shown once and is not stored.
  def self.issue!(user:, name:)
    raw = SecureRandom.urlsafe_base64(32)
    record = create!(user: user, name: name, token_digest: digest(raw))
    [ record, raw ]
  end
end
