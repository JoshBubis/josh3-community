module ApplicationHelper
  def markdown(text)
    MarkdownRenderer.to_html(text)
  end

  def vote_value(votable)
    votable.vote_from(current_user)&.value
  end

  def external_url(url)
    url if url.to_s.match?(%r{\Ahttps?://[^\s]+\z}i)
  end
end
