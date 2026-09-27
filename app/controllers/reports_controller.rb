class ReportsController < ApplicationController
  before_action :require_user

  def create
    reportable = find_reportable
    if reportable.nil?
      redirect_back fallback_location: root_path, alert: "That item was not found."
      return
    end

    report = current_user.reports.new(reportable: reportable, reason: params[:reason])
    if report.save
      redirect_back fallback_location: root_path, notice: "Report sent."
    else
      redirect_back fallback_location: root_path, alert: report.errors.full_messages.to_sentence
    end
  end

  private

  def find_reportable
    case params[:reportable_type]
    when "Post" then Post.find_by(id: params[:reportable_id])
    when "Comment" then Comment.find_by(id: params[:reportable_id])
    end
  end
end
