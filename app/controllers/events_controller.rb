class EventsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @events = Event.upcoming.by_category(params[:category])
  end

  def show
  end

  def new
    @event = Event.new
    @images = Image.order(created_at: :desc)
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: "Event was successfully created."
    else
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
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: "Event was successfully deleted.", status: :see_other
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.expect(event: [:title, :description, :event_date, :start_time, :end_time, :location, :category, :image_id])
  end
end
