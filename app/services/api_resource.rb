class ApiResource
  def self.user(user, view, include_email: false)
    payload = {
      username: user.username,
      bio: user.bio,
      avatar_url: avatar_url(user, view)
    }
    payload[:email] = user.email if include_email
    payload[:admin] = user.admin? if include_email
    payload
  end

  def self.post(post, view)
    {
      id: post.id,
      title: post.removed? ? "[removed]" : post.title,
      body: post.removed? ? nil : post.body,
      body_html: post.removed? ? nil : MarkdownRenderer.to_html(post.body),
      link_url: post.removed? ? nil : post.link_url,
      score: post.score,
      hot_score: post.hot_score.to_f,
      locked: post.locked?,
      removed: post.removed?,
      channel: post.channel.slug,
      author: user(post.user, view),
      created_at: post.created_at.iso8601,
      url: view.post_url(post)
    }
  end

  def self.comment(comment, view)
    {
      id: comment.id,
      post_id: comment.post_id,
      parent_id: comment.parent_id,
      body: comment.removed? ? nil : comment.body,
      body_html: comment.removed? ? nil : MarkdownRenderer.to_html(comment.body),
      removed: comment.removed?,
      score: comment.score,
      author: user(comment.user, view),
      created_at: comment.created_at.iso8601
    }
  end

  def self.channel(channel)
    {
      slug: channel.slug,
      name: channel.name,
      description: channel.description
    }
  end

  def self.avatar_url(user, view)
    return unless user.avatar.attached?

    view.rails_blob_url(user.avatar)
  end
end
