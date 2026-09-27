# Renders untrusted markdown to a small set of HTML tags.
class MarkdownRenderer
  TAGS = %w[p br strong em a ul ol li code pre blockquote h1 h2 h3 h4].freeze
  ATTRIBUTES = %w[href].freeze

  def self.to_html(text)
    html = Kramdown::Document.new(
      text.to_s,
      input: "GFM",
      syntax_highlighter: nil,
      hard_wrap: false
    ).to_html
    ActionController::Base.helpers.sanitize(html, tags: TAGS, attributes: ATTRIBUTES)
  end
end
