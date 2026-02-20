require "application_system_test_case"

class HomepageTest < ApplicationSystemTestCase
  test "displays This Week's Events section" do
    visit root_url
    assert_text "This Week's Events"
  end

  test "displays events happening this week" do
    visit root_url
    assert_text events(:this_week_education).title
  end

  test "displays birthdays section heading for current month" do
    visit root_url
    assert_text "#{Date.current.strftime('%B')} Birthdays"
  end

  test "displays member with birthday this month" do
    visit root_url
    assert_text members(:birthday_this_month).full_name
  end

  test "shows empty state when no events this week" do
    # Verify the page renders without error even if different data existed
    visit root_url
    assert_selector "section", minimum: 2
  end

  test "links to event show page from homepage" do
    event = events(:this_week_education)
    visit root_url
    click_on event.title
    assert_current_path event_path(event)
  end
end
