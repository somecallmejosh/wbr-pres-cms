require "test_helper"

class EventTest < ActiveSupport::TestCase
  # Constants

  test "CATEGORIES returns expected values" do
    assert_equal %w[education fellowship meetings community_service], Event::CATEGORIES
  end

  test "CATEGORY_LABELS returns expected labels" do
    assert_equal "Education", Event::CATEGORY_LABELS["education"]
    assert_equal "Community Service", Event::CATEGORY_LABELS["community_service"]
  end

  # Validations

  test "valid with all required attributes" do
    event = Event.new(title: "Test Event", event_date: Date.current, start_time: "10:00", category: "education")
    assert event.valid?
  end

  test "invalid without title" do
    event = Event.new(event_date: Date.current, start_time: "10:00", category: "education")
    assert_not event.valid?
    assert event.errors[:title].any?
  end

  test "title cannot exceed 255 characters" do
    event = Event.new(title: "a" * 256, event_date: Date.current, start_time: "10:00", category: "education")
    assert_not event.valid?
    assert event.errors[:title].any?
  end

  test "invalid without event_date" do
    event = Event.new(title: "Test", start_time: "10:00", category: "education")
    assert_not event.valid?
    assert event.errors[:event_date].any?
  end

  test "invalid without start_time" do
    event = Event.new(title: "Test", event_date: Date.current, category: "education")
    assert_not event.valid?
    assert event.errors[:start_time].any?
  end

  test "invalid without category" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00")
    assert_not event.valid?
    assert event.errors[:category].any?
  end

  test "invalid with unknown category" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00", category: "unknown")
    assert_not event.valid?
    assert event.errors[:category].any?
  end

  test "description cannot exceed 5000 characters" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00", category: "education", description: "a" * 5001)
    assert_not event.valid?
    assert event.errors[:description].any?
  end

  test "location cannot exceed 255 characters" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00", category: "education", location: "a" * 256)
    assert_not event.valid?
    assert event.errors[:location].any?
  end

  test "end_time must be after start_time" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00", end_time: "09:00", category: "education")
    assert_not event.valid?
    assert event.errors[:end_time].any?
  end

  test "end_time equal to start_time is invalid" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00", end_time: "10:00", category: "education")
    assert_not event.valid?
    assert event.errors[:end_time].any?
  end

  test "end_time after start_time is valid" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00", end_time: "11:00", category: "education")
    assert event.valid?
  end

  test "end_time is optional" do
    event = Event.new(title: "Test", event_date: Date.current, start_time: "10:00", category: "education")
    assert event.valid?
  end

  # Scopes

  test "upcoming scope returns events from today forward" do
    results = Event.upcoming
    results.each do |event|
      assert event.event_date >= Date.current
    end
    assert_not_includes results, events(:past_event)
  end

  test "this_week scope returns events within current week" do
    results = Event.this_week
    week_range = Date.current.beginning_of_week..Date.current.end_of_week
    results.each do |event|
      assert_includes week_range, event.event_date
    end
  end

  test "this_week scope includes this week's events" do
    assert_includes Event.this_week, events(:this_week_education)
  end

  test "for_month scope returns events for given month" do
    date = Date.current
    results = Event.for_month(date)
    results.each do |event|
      assert_equal date.month, event.event_date.month
      assert_equal date.year, event.event_date.year
    end
  end

  test "by_category scope filters by category" do
    results = Event.by_category("education")
    results.each do |event|
      assert_equal "education", event.category
    end
  end

  test "by_category scope returns all when blank" do
    assert_equal Event.count, Event.by_category(nil).count
    assert_equal Event.count, Event.by_category("").count
  end
end
