class Channel < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  scope :listed, -> { order(:position, :name) }

  SEEDS = [
    { slug: "general", name: "General", description: "Anything that fits the site.", position: 1 },
    { slug: "ai", name: "AI", description: "Artificial intelligence news and tools.", position: 2 },
    { slug: "tech", name: "Tech", description: "Software, hardware, and how things are built.", position: 3 },
    { slug: "meta", name: "Meta", description: "The site itself.", position: 4 }
  ].freeze

  def self.seed!
    SEEDS.each do |attrs|
      find_or_create_by!(slug: attrs[:slug]) do |channel|
        channel.name = attrs[:name]
        channel.description = attrs[:description]
        channel.position = attrs[:position]
      end
    end
  end

  def to_param
    slug
  end
end
