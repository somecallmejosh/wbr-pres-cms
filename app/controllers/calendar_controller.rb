class CalendarController < ApplicationController
  allow_unauthenticated_access

  def show
    @date = parse_date_params
    @category = params[:category]
    @events = Event.for_month(@date).by_category(@category).includes(:image)
    @events_by_date = @events.group_by(&:event_date)
  end

  private

  def parse_date_params
    if params[:month].present? && params[:year].present?
      Date.new(params[:year].to_i.clamp(1900, 2100), params[:month].to_i.clamp(1, 12), 1)
    else
      Date.current
    end
  end
end
