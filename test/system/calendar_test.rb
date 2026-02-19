require "application_system_test_case"

class CalendarTest < ApplicationSystemTestCase
  test "displays current month and year" do
    visit calendar_url
    assert_text Date.current.strftime("%B %Y")
  end

  test "displays day-of-week headers" do
    visit calendar_url
    assert_text "Sun"
    assert_text "Mon"
    assert_text "Sat"
  end

  test "displays events on their dates" do
    event = events(:this_week_education)
    visit calendar_url(month: event.event_date.month, year: event.event_date.year)
    assert_text event.title
  end

  test "event title links to event show page" do
    event = events(:this_week_education)
    visit calendar_url(month: event.event_date.month, year: event.event_date.year)
    click_on event.title
    assert_current_path event_path(event)
  end

  test "navigates to next month" do
    visit calendar_url
    next_month = Date.current.next_month
    click_on "Next"
    assert_text next_month.strftime("%B %Y")
  end

  test "navigates to previous month" do
    visit calendar_url
    prev_month = Date.current.prev_month
    click_on "Previous"
    assert_text prev_month.strftime("%B %Y")
  end

  test "category filter shows matching events" do
    event = events(:this_week_education)
    visit calendar_url(month: event.event_date.month, year: event.event_date.year)
    click_on "Education"
    assert_text event.title
  end

  test "all filter link shows all events" do
    event = events(:this_week_education)
    visit calendar_url(
      month: event.event_date.month,
      year: event.event_date.year,
      category: "education"
    )
    click_on "All"
    assert_text event.title
  end

  test "highlights today's date" do
    visit calendar_url
    # Today's cell has the bg-blue-50 class applied
    assert_selector "div.bg-blue-50", minimum: 1
  end
end
