module EventsHelper
  def category_badge_class(category)
    case category
    when "education"         then "bg-blue-100 text-blue-900"
    when "fellowship"        then "bg-green-100 text-green-800"
    when "meetings"          then "bg-amber-100 text-amber-800"
    when "community_service" then "bg-stone-100 text-stone-800"
    else "bg-stone-100 text-stone-800"
    end
  end

  def category_label(category)
    Event::CATEGORY_LABELS.fetch(category, category.titleize)
  end

  # Solid dot color used to flag an event's category on the calendar.
  def category_dot_class(category)
    case category
    when "education"         then "bg-blue-500"
    when "fellowship"        then "bg-emerald-500"
    when "meetings"          then "bg-amber-500"
    when "community_service" then "bg-rose-400"
    else "bg-stone-400"
    end
  end

  # Soft, category-tinted chip used for an event link inside a calendar cell or
  # the mobile agenda. Replaces the flat stone pill so the grid reads as a warm,
  # color-coded map of the month rather than a spreadsheet.
  def category_chip_class(category)
    case category
    when "education"         then "bg-blue-50/80 text-blue-900 ring-blue-600/[0.08] hover:bg-blue-50 hover:ring-blue-600/25"
    when "fellowship"        then "bg-emerald-50/80 text-emerald-900 ring-emerald-600/[0.08] hover:bg-emerald-50 hover:ring-emerald-600/25"
    when "meetings"          then "bg-amber-50/80 text-amber-900 ring-amber-600/[0.08] hover:bg-amber-50 hover:ring-amber-600/30"
    when "community_service" then "bg-rose-50/80 text-rose-900 ring-rose-500/[0.08] hover:bg-rose-50 hover:ring-rose-500/25"
    else "bg-stone-100/80 text-stone-700 ring-stone-900/[0.03] hover:bg-stone-100 hover:ring-stone-900/10"
    end
  end

  # Hairline accent bar color anchoring an event card in the mobile agenda.
  def category_accent_class(category)
    case category
    when "education"         then "bg-blue-400"
    when "fellowship"        then "bg-emerald-400"
    when "meetings"          then "bg-amber-400"
    when "community_service" then "bg-rose-400"
    else "bg-stone-300"
    end
  end

  # Filled style for an *active* category filter pill, so the chosen filter
  # glows in its own hue instead of generic stone.
  def category_filter_active_class(category)
    case category
    when "education"         then "bg-blue-600 text-white shadow-[0_8px_20px_-10px_rgba(37,99,235,0.8)]"
    when "fellowship"        then "bg-emerald-600 text-white shadow-[0_8px_20px_-10px_rgba(5,150,105,0.8)]"
    when "meetings"          then "bg-amber-600 text-white shadow-[0_8px_20px_-10px_rgba(217,119,6,0.85)]"
    when "community_service" then "bg-rose-500 text-white shadow-[0_8px_20px_-10px_rgba(225,29,72,0.8)]"
    else "bg-stone-800 text-white shadow-sm"
    end
  end

  # Floating-local calendar stamp ("20260705T100000") for calendar deep-links.
  def calendar_stamp(date, time)
    return if date.blank? || time.blank?
    Time.new(date.year, date.month, date.day, time.hour, time.min).strftime("%Y%m%dT%H%M%S")
  end

  # "Add to Google Calendar" deep link. Falls back to a one-hour block when the
  # event has no explicit end time.
  def google_calendar_url(event)
    finish = event.end_time || event.start_time + 1.hour
    params = {
      action: "TEMPLATE",
      text: event.title,
      dates: "#{calendar_stamp(event.event_date, event.start_time)}/#{calendar_stamp(event.event_date, finish)}",
      details: event.description,
      location: event.location
    }.compact_blank
    "https://calendar.google.com/calendar/render?#{params.to_query}"
  end

  # Google Maps directions link for an event's location.
  def event_directions_url(event)
    return if event.location.blank?
    "https://www.google.com/maps/dir/?api=1&destination=#{CGI.escape(event.location)}"
  end

  # schema.org/Event structured data for an event detail page. Emitted via
  # `content_for :json_ld` so a share/search result shows date, place, and image.
  def event_json_ld(event)
    data = {
      "@context" => "https://schema.org",
      "@type" => "Event",
      "name" => event.title,
      "startDate" => event_iso8601(event.event_date, event.start_time),
      "eventStatus" => "https://schema.org/EventScheduled",
      "eventAttendanceMode" => "https://schema.org/OfflineEventAttendanceMode",
      "url" => event_url(event),
      "image" => og_image_url(event.image),
      "location" => {
        "@type" => "Place",
        "name" => event.location.presence || "West Baton Rouge Presbyterian Church",
        "address" => {
          "@type" => "PostalAddress",
          "streetAddress" => "640 Florida Ave",
          "addressLocality" => "Port Allen",
          "addressRegion" => "LA",
          "postalCode" => "70767",
          "addressCountry" => "US"
        }
      },
      "organizer" => {
        "@type" => "Organization",
        "name" => "West Baton Rouge Presbyterian Church",
        "url" => root_url
      }
    }
    data["endDate"] = event_iso8601(event.event_date, event.end_time) if event.end_time.present?
    if event.description.present?
      data["description"] = truncate(strip_tags(event.description).squish, length: 300)
    end
    data
  end

  private

  # ISO 8601 timestamp built from an event's date column + a time column (whose
  # own date part is irrelevant), mirroring #calendar_stamp's date/time merge.
  def event_iso8601(date, time)
    return if date.blank?
    return date.iso8601 if time.blank?
    Time.zone.local(date.year, date.month, date.day, time.hour, time.min).iso8601
  end
end
