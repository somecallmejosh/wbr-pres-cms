class Event < ApplicationRecord
  belongs_to :image, optional: true

  CATEGORIES = %w[education fellowship meetings community_service].freeze

  CATEGORY_LABELS = {
    "education" => "Education",
    "fellowship" => "Fellowship",
    "meetings" => "Meetings",
    "community_service" => "Community Service"
  }.freeze

  scope :upcoming, -> { where("event_date >= ?", Date.current).order(event_date: :asc, start_time: :asc) }
  scope :this_week, -> { where(event_date: Date.current.beginning_of_week..Date.current.end_of_week).order(event_date: :asc, start_time: :asc) }
  scope :for_month, ->(date) { where(event_date: date.beginning_of_month..date.end_of_month) }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }, allow_blank: true
  validates :event_date, presence: true
  validates :start_time, presence: true
  validates :location, length: { maximum: 255 }, allow_blank: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    if end_time.present? && start_time.present? && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
