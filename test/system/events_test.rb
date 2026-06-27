require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  # Visitor viewing

  test "visitor can view events index" do
    visit events_url
    assert_text "Events"
    assert_text events(:this_week_education).title
  end

  test "visitor can view event detail page" do
    event = events(:this_week_education)
    visit event_url(event)
    assert_text event.title
  end

  test "visitor does not see admin buttons on index" do
    visit events_url
    assert_no_text "New Event"
  end

  test "visitor does not see edit or delete buttons on show" do
    visit event_url(events(:this_week_education))
    assert_no_text "Edit"
    assert_no_text "Delete"
  end

  # Category filter

  test "category filter shows matching events" do
    visit events_url
    click_on "Education"
    assert_text events(:this_week_education).title
  end

  test "category filter hides non-matching events" do
    visit events_url
    click_on "Fellowship"
    assert_no_text events(:this_week_education).title
  end

  # Admin CRUD

  test "admin can create an event" do
    sign_in_as_admin
    visit new_event_url
    fill_in "Title", with: "New System Test Event"
    execute_script("document.querySelector('#event_event_date').value = '2026-06-15'")
    execute_script("document.querySelector('#event_start_time').value = '10:00'")
    select "Education", from: "Category"
    # Use native form.submit() to bypass Turbo's form submission handler
    execute_script("document.querySelector('form').submit()")
    assert_text "New System Test Event"
  end

  test "admin can edit an event" do
    sign_in_as_admin
    event = events(:this_week_education)
    visit edit_event_url(event)
    fill_in "Title", with: "Updated Event Title"
    click_button "Save event"
    assert_text "Updated Event Title"
  end

  test "admin can delete an event" do
    sign_in_as_admin
    event = events(:past_event)
    visit event_url(event)
    accept_confirm { click_button "Delete" }
    assert_current_path events_path
  end

  test "admin sees edit and delete buttons on event show" do
    sign_in_as_admin
    visit event_url(events(:this_week_education))
    assert_text "Edit"
    assert_text "Delete"
  end
end
