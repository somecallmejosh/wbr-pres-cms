require "application_system_test_case"

class CalendarTest < ApplicationSystemTestCase
  test "displays current month and year" do
    visit calendar_url
    assert_text Date.current.strftime("%B %Y")
  end

  test "displays day-of-week headers" do
    visit calendar_url
    # Headers are styled uppercase via CSS, so the rendered text is uppercased.
    assert_text "SUN"
    assert_text "MON"
    assert_text "SAT"
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
    find("a[aria-label^='Next month']").click
    assert_text next_month.strftime("%B %Y")
  end

  test "navigates to previous month" do
    visit calendar_url
    prev_month = Date.current.prev_month
    find("a[aria-label^='Previous month']").click
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
    # Today's cell (desktop grid or mobile agenda) is flagged with aria-current="date"
    assert_selector "[aria-current='date']", minimum: 1
  end

  test "admin adds an event from a calendar day via the modal" do
    sign_in_as_admin
    visit calendar_url(month: 7, year: 2026)

    # The day cells expose an "Add an event on <date>" trigger for admins.
    # Desktop "+" is hover-revealed (opacity-0); target it directly and click.
    find("a[aria-label='Add an event on Saturday, July 4th']", match: :first, visible: :all).click

    assert_selector "dialog[open]"
    assert_field "Date", with: "2026-07-04"
    # Selenium's pointer/keyboard interactions inside a top-layer <dialog> are
    # unreliable, so set the field values and trigger the real form submission
    # via requestSubmit() — Turbo still intercepts it, exercising the genuine
    # create -> Turbo Stream -> modal-close -> calendar-refresh path.
    execute_script(<<~JS)
      const d = document.querySelector("dialog[open]")
      d.querySelector("#event_title").value = "Patriotic Picnic"
      d.querySelector("#event_start_time").value = "12:00"
      d.querySelector("#event_category").value = "fellowship"
      d.querySelector("form").requestSubmit()
    JS

    # Modal closes and the new event shows up in the refreshed calendar.
    assert_no_selector "dialog[open]"
    assert_text "Patriotic Picnic"
    assert_text "Event was successfully created."
  end

  test "admin can dismiss the new-event modal" do
    sign_in_as_admin
    visit calendar_url(month: 7, year: 2026)
    # Desktop "+" is hover-revealed (opacity-0); target it directly and click.
    find("a[aria-label='Add an event on Saturday, July 4th']", match: :first, visible: :all).click
    assert_selector "dialog[open]"
    # Pointer/keyboard events inside a top-layer <dialog> are flaky under
    # Selenium; dispatch a real click on the close control so the actual
    # modal#close handler runs.
    execute_script(%(document.querySelector("dialog[open] [aria-label='Close']").click()))
    assert_no_selector "dialog[open]"
  end
end
