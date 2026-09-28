module Admin
  class ReportsController < ApplicationController
    before_action :require_admin

    def index
      @reports = Report.open_reports.includes(:user)
    end

    def update
      report = Report.find(params[:id])
      report.update!(status: "closed")
      redirect_to admin_reports_path, notice: "Report closed."
    end
  end
end
