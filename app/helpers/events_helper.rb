module EventsHelper
  def category_badge_class(category)
    case category
    when "education"         then "bg-blue-100 text-blue-800"
    when "fellowship"        then "bg-green-100 text-green-800"
    when "meetings"          then "bg-yellow-100 text-yellow-800"
    when "community_service" then "bg-purple-100 text-purple-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  def category_label(category)
    Event::CATEGORY_LABELS.fetch(category, category.titleize)
  end
end
