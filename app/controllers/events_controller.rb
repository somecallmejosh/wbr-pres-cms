class EventsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_event, only: %i[show edit update destroy update_image]

  def index
    @events = Event.upcoming.by_category(params[:category])
  end

  def show
    @related_events = Event.upcoming.where.not(id: @event.id).limit(3)
  end

  def new
    @event = Event.new(event_date: parse_prefill_date)
    @images = Image.order(created_at: :desc)
    @calendar_context = { month: params[:month], year: params[:year], category: params[:category] }
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      if turbo_frame_request_id == "modal"
        refresh_calendar_context
        flash.now[:notice] = "Event was successfully created."
        render :create # create.turbo_stream.erb — closes modal, refreshes grid
      else
        redirect_to @event, notice: "Event was successfully created."
      end
    else
      @images = Image.order(created_at: :desc)
      @calendar_context = { month: params[:cal_month], year: params[:cal_year], category: params[:cal_category] }
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @images = Image.order(created_at: :desc)
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      @images = Image.order(created_at: :desc)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: "Event was successfully deleted.", status: :see_other
  end

  # Live featured-photo picker on the edit page. Persists only image_id so the
  # admin sees the choice stick instantly; the JS controller updates the preview
  # optimistically, so a bare 204 is all we owe it.
  def update_image
    if @event.update(image_id: params.dig(:event, :image_id).presence)
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  # Optional ?date=YYYY-MM-DD used to pre-select the day when an admin adds an
  # event straight from a calendar cell. Ignores anything unparseable.
  def parse_prefill_date
    Date.iso8601(params[:date]) if params[:date].present?
  rescue ArgumentError
    nil
  end

  # Rebuild the month/category the admin was viewing so create.turbo_stream.erb
  # can re-render the calendar grid in place. Falls back to the new event's
  # own month if the hidden context is missing.
  def refresh_calendar_context
    @date =
      begin
        Date.new(params[:cal_year].to_i, params[:cal_month].to_i, 1)
      rescue ArgumentError, Date::Error
        @event.event_date.beginning_of_month
      end
    @category = params[:cal_category].presence
    @events = Event.for_month(@date).by_category(@category).includes(:image)
    @events_by_date = @events.group_by(&:event_date)
  end

  def event_params
    params.expect(event: [ :title, :description, :event_date, :start_time, :end_time, :location, :category, :image_id ])
  end
end
