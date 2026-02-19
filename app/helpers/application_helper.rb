module ApplicationHelper
  def ordinalize_day(date)
    date.day.ordinalize
  end

  # "February 5th"
  def month_day_ordinal(date)
    "#{date.strftime('%B')} #{ordinalize_day(date)}"
  end

  # "Wednesday, February 19th"
  def full_date_ordinal(date)
    "#{date.strftime('%A')}, #{month_day_ordinal(date)}"
  end

  # "Wednesday, February 19th, 2026"
  def full_date_ordinal_with_year(date)
    "#{full_date_ordinal(date)}, #{date.year}"
  end

  def format_time(time)
    time&.strftime("%-I:%M %p")
  end

  # "10:00 AM - 11:30 AM" or "10:00 AM"
  def event_time_range(event)
    start = format_time(event.start_time)
    event.end_time.present? ? "#{start} - #{format_time(event.end_time)}" : start
  end
end
