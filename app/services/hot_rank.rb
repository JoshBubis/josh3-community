# Simplified hot ranking: magnitude of the score, plus age.
# Newer posts rank above older posts with the same score.
# One hour of age is worth about 0.08 points (3600 / 45_000).
class HotRank
  EPOCH_DIVISOR = 45_000.0

  def self.score_for(points, created_at)
    points = points.to_i
    magnitude = Math.log10([ points.abs, 1 ].max)
    sign = points <=> 0
    (sign * magnitude) + (created_at.to_f / EPOCH_DIVISOR)
  end
end
