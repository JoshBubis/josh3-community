require "test_helper"

class CommunityRulesTest < ActiveSupport::TestCase
  test "markdown keeps emphasis and drops scripts" do
    html = MarkdownRenderer.to_html("Hello **world** <script>alert(1)</script> <img src=x onerror=alert(1)>")
    assert_includes html, "<strong>world</strong>"
    assert_not_includes html, "<script"
    assert_not_includes html, "<img"
    assert_includes html, "&lt;img"
  end

  test "voting the same way again clears the vote" do
    user = User.create!(email: "ada@example.com", username: "ada", password: "password1", password_confirmation: "password1", accepted_terms: "1")
    post = user.posts.create!(channel: channels(:ai), title: "Hi", body: "There")

    Vote.cast!(user: user, votable: post, direction: "up")
    assert_equal 1, post.reload.score

    Vote.cast!(user: user, votable: post, direction: "up")
    assert_equal 0, post.reload.score
    assert_operator post.hot_score, :>, 0
  end

  test "a reply must stay on the same post" do
    user = User.create!(email: "bea@example.com", username: "bea", password: "password1", password_confirmation: "password1", accepted_terms: "1")
    first = user.posts.create!(channel: channels(:ai), title: "One", body: "A")
    second = user.posts.create!(channel: channels(:tech), title: "Two", body: "B")
    parent = first.comments.create!(user: user, body: "Parent")
    reply = second.comments.new(user: user, body: "Nope", parent: parent)

    assert_not reply.valid?
  end
end
