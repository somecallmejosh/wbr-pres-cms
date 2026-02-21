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
end
