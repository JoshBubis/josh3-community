class PagesController < ApplicationController
  def terms
  end

  def norms
  end

  def api
    @doc = Rails.root.join("docs/API.md").read
  end

  # Preserved from the previous static josh3.com: the about page and the
  # Reddit OAuth callback must keep working after the community cutover.
  def about
  end

  def reddit_callback
  end
end
