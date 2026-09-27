class PagesController < ApplicationController
  def terms
  end

  def norms
  end

  def api
    @doc = Rails.root.join("docs/API.md").read
  end
end
