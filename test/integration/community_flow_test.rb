require "test_helper"

class CommunityFlowTest < ActionDispatch::IntegrationTest
  test "signup, post, comment, and vote" do
    post signup_path, params: {
      user: {
        email: "ada@example.com",
        username: "ada",
        password: "password1",
        password_confirmation: "password1",
        bio: "Writes here.",
        accepted_terms: "1"
      }
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_match "responsible", response.body

    get new_post_path
    assert_response :success

    post posts_path, params: { post: { channel_id: channels(:ai).id, title: "A sourced note", body: "The **source** says so.", link_url: "" } }
    story = Post.find_by!(title: "A sourced note")
    assert_redirected_to post_path(story)
    follow_redirect!
    assert_match "source", response.body
    assert_match "<strong>source</strong>", response.body

    post post_comments_path(story), params: { comment: { body: "And a reply." } }
    assert_redirected_to post_path(story, anchor: "comment-#{story.comments.last.id}")

    post votes_path, params: { votable_type: "Post", votable_id: story.id, direction: "up" }
    assert_equal 1, story.reload.score
  end

  test "signup without accepting the terms is rejected" do
    post signup_path, params: {
      user: {
        email: "nope@example.com",
        username: "nope",
        password: "password1",
        password_confirmation: "password1",
        accepted_terms: "0"
      }
    }
    assert_response :unprocessable_entity
    assert_equal 0, User.where(email: "nope@example.com").count
  end

  test "terms put responsibility on the account holder and do not invent personhood" do
    get terms_path
    assert_response :success
    assert_match "human or a company", response.body
    assert_match "responsible for everything posted", response.body
    assert_no_match(/personhood/i, response.body)

    get root_path
    assert_no_match(/agent-friendly/i, response.body)
    assert_no_match(/personhood/i, response.body)
  end

  test "a moderator can remove a post and others cannot" do
    author = User.create!(email: "ada@example.com", username: "ada", password: "password1", password_confirmation: "password1", accepted_terms: "1")
    story = author.posts.create!(channel: channels(:meta), title: "Oops", body: "Private phone 555")
    reader = User.create!(email: "bea@example.com", username: "bea", password: "password1", password_confirmation: "password1", accepted_terms: "1")

    post login_path, params: { email: reader.email, password: "password1" }
    patch admin_post_path(story), params: { removed: "1" }
    assert_redirected_to root_path
    assert_not story.reload.removed?

    moderator = User.create!(email: "mod@example.com", username: "mod", password: "password1", password_confirmation: "password1", accepted_terms: "1", admin: true)
    post login_path, params: { email: moderator.email, password: "password1" }
    patch admin_post_path(story), params: { removed: "1" }
    assert_redirected_to post_path(story)
    assert story.reload.removed?

    get post_path(story)
    assert_match "[removed]", response.body
    assert_no_match(/555/, response.body)
  end
end
