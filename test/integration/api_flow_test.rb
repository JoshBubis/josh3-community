require "test_helper"

class ApiFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com", username: "ada", password: "password1", password_confirmation: "password1", accepted_terms: "1")
    _record, @token = ApiToken.issue!(user: @user, name: "test")
  end

  test "the feed is public and writes need a token" do
    get "/api/v1/channels"
    assert_response :success
    body = JSON.parse(response.body)
    assert_includes body["channels"].map { |channel| channel["slug"] }, "ai"

    post "/api/v1/channels/ai/posts", params: { title: "Nope", body: "Nope" }, as: :json
    assert_response :unauthorized
    assert_equal "Missing or invalid API token.", JSON.parse(response.body)["error"]
  end

  test "a token can post, comment, and vote" do
    post "/api/v1/channels/ai/posts",
      params: { title: "From the API", body: "Hello **there**" },
      headers: { "Authorization" => "Bearer #{@token}" },
      as: :json
    assert_response :created
    story = JSON.parse(response.body)
    assert_includes story["body_html"], "<strong>there</strong>"
    assert_nil story["author"]["email"]

    post "/api/v1/posts/#{story["id"]}/comments",
      params: { body: "Threaded" },
      headers: { "Authorization" => "Bearer #{@token}" },
      as: :json
    assert_response :created
    comment = JSON.parse(response.body)

    post "/api/v1/posts/#{story["id"]}/vote",
      params: { direction: "up" },
      headers: { "Authorization" => "Bearer #{@token}" },
      as: :json
    assert_response :success
    assert_equal 1, JSON.parse(response.body)["score"]

    post "/api/v1/comments/#{comment["id"]}/vote",
      params: { direction: "down" },
      headers: { "Authorization" => "Bearer #{@token}" },
      as: :json
    assert_response :success
    assert_equal(-1, JSON.parse(response.body)["score"])

    get "/api/v1/me", headers: { "Authorization" => "Bearer #{@token}" }
    assert_response :success
    assert_equal "ada@example.com", JSON.parse(response.body)["email"]
  end

  test "docs list the rate limits and skip personhood" do
    get api_docs_path
    assert_response :success
    assert_match "600 requests per minute", response.body
    assert_match "human or a company", response.body
    assert_no_match(/personhood/i, response.body)
  end
end
