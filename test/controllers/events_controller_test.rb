require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @event = events(:this_week_education)
    sign_in_as(@user)
  end

  # Public access tests

  test "index is publicly accessible" do
    sign_out
    get events_url
    assert_response :success
  end

  test "show is publicly accessible" do
    sign_out
    get event_url(@event)
    assert_response :success
  end

  # Auth tests

  test "new requires authentication" do
    sign_out
    get new_event_url
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    sign_out
    post events_url, params: { event: { title: "Test", event_date: Date.current, start_time: "10:00", category: "education" } }
    assert_redirected_to new_session_path
  end

  test "edit requires authentication" do
    sign_out
    get edit_event_url(@event)
    assert_redirected_to new_session_path
  end

  test "update requires authentication" do
    sign_out
    patch event_url(@event), params: { event: { title: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "destroy requires authentication" do
    sign_out
    delete event_url(@event)
    assert_redirected_to new_session_path
  end

  # CRUD tests

  test "should get index" do
    get events_url
    assert_response :success
  end

  test "should filter index by category" do
    get events_url(category: "education")
    assert_response :success
  end

  test "should get new" do
    get new_event_url
    assert_response :success
  end

  test "should create event" do
    assert_difference("Event.count") do
      post events_url, params: { event: { title: "New Event", event_date: Date.current, start_time: "10:00", category: "education" } }
    end

    assert_redirected_to event_url(Event.last)
  end

  test "should not create event with invalid data" do
    assert_no_difference("Event.count") do
      post events_url, params: { event: { title: "", event_date: "", start_time: "", category: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should show event" do
    get event_url(@event)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_url(@event)
    assert_response :success
  end

  test "should update event" do
    patch event_url(@event), params: { event: { title: "Updated Title" } }
    assert_redirected_to event_url(@event)
    @event.reload
    assert_equal "Updated Title", @event.title
  end

  test "should not update event with invalid data" do
    patch event_url(@event), params: { event: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_url
  end
end
