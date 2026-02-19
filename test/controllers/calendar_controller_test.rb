require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  # Public access

  test "show is publicly accessible" do
    get calendar_url
    assert_response :success
  end

  test "show does not require authentication" do
    get calendar_url
    assert_response :success
    assert_not_equal new_session_path, response.location
  end

  # Month parsing

  test "defaults to current month when no params given" do
    get calendar_url
    assert_response :success
    assert_match Date.current.strftime("%B %Y"), response.body
  end

  test "accepts month and year params" do
    get calendar_url(month: 3, year: 2025)
    assert_response :success
    assert_match "March 2025", response.body
  end

  test "renders previous month link" do
    get calendar_url(month: 6, year: 2025)
    assert_response :success
    assert_match "month=5", response.body
    assert_match "year=2025", response.body
  end

  test "renders next month link" do
    get calendar_url(month: 6, year: 2025)
    assert_response :success
    assert_match "month=7", response.body
    assert_match "year=2025", response.body
  end

  # Category filtering

  test "accepts category param" do
    get calendar_url(category: "education")
    assert_response :success
  end

  test "shows events for the requested month" do
    event = events(:this_week_education)
    get calendar_url(month: event.event_date.month, year: event.event_date.year)
    assert_response :success
    assert_match event.title, response.body
  end

  test "does not show events from other months" do
    get calendar_url(month: events(:next_month_event).event_date.month, year: events(:next_month_event).event_date.year)
    assert_response :success
    assert_no_match events(:past_event).title, response.body
  end

  test "filters events by category" do
    event = events(:this_week_education)
    get calendar_url(
      month: event.event_date.month,
      year: event.event_date.year,
      category: "education"
    )
    assert_response :success
    assert_match event.title, response.body
  end

  test "category filter excludes non-matching events" do
    education_event = events(:this_week_education)
    meeting_event = events(:this_week_meeting)

    # Both events are in the same month; filter by education should exclude meetings
    get calendar_url(
      month: education_event.event_date.month,
      year: education_event.event_date.year,
      category: "education"
    )
    assert_response :success
    assert_match education_event.title, response.body

    # Only check this if the meeting is also in the same month
    if meeting_event.event_date.month == education_event.event_date.month
      assert_no_match meeting_event.title, response.body
    end
  end
end
