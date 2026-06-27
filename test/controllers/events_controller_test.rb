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

  test "new pre-selects the date param on the form" do
    get new_event_url(date: "2026-07-04")
    assert_response :success
    assert_select "input[name='event[event_date]'][value='2026-07-04']"
  end

  test "new ignores an unparseable date param" do
    get new_event_url(date: "not-a-date")
    assert_response :success
    assert_select "input[name='event[event_date]']"
    assert_select "input[name='event[event_date]'][value]", false
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

  # Calendar modal flow (Turbo-Frame: modal)

  test "new in the modal frame renders a dialog" do
    get new_event_url(date: "2026-07-04", month: 7, year: 2026), headers: { "Turbo-Frame" => "modal" }
    assert_response :success
    assert_select "turbo-frame#modal dialog"
    assert_select "input[name='event[event_date]'][value='2026-07-04']"
  end

  test "creating from the modal returns a turbo stream that closes it and refreshes the calendar" do
    assert_difference("Event.count") do
      post events_url,
        params: { event: { title: "Modal Event", event_date: "2026-07-04", start_time: "10:00", category: "education" },
                  cal_month: 7, cal_year: 2026 },
        headers: { "Turbo-Frame" => "modal" },
        as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match %r{<turbo-stream action="update" target="modal">}, response.body
    assert_match %r{<turbo-stream action="replace" target="calendar_frame">}, response.body
    assert_match "Modal Event", response.body
  end

  test "invalid create from the modal re-renders the dialog with errors" do
    assert_no_difference("Event.count") do
      post events_url,
        params: { event: { title: "", event_date: "", start_time: "", category: "" }, cal_month: 7, cal_year: 2026 },
        headers: { "Turbo-Frame" => "modal" }
    end

    assert_response :unprocessable_entity
    assert_select "turbo-frame#modal dialog"
  end

  test "should show event" do
    get event_url(@event)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_url(@event)
    assert_response :success
  end

  test "edit wires the upload link to the modal frame" do
    get edit_event_url(@event)
    assert_response :success
    # Picker tiles land in a streamable container...
    assert_select "#event-image-options"
    # ...and the "Upload a new photo" link targets the modal frame.
    assert_select "a[data-turbo-frame='upload_modal'][href=?]", new_admin_image_path
    assert_select "turbo-frame#upload_modal"
  end

  test "photo picker and upload entry still show when the library is empty" do
    Image.destroy_all # cascades: nullifies events, destroys gallery joins

    get edit_event_url(@event)
    assert_response :success
    assert_select "a[data-turbo-frame='upload_modal']"
    assert_select "#event-image-options"
    assert_match "Your photo library is empty", response.body
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

  test "update_image persists just the image and returns no content" do
    image = images(:sanctuary)
    patch image_event_url(@event), params: { event: { image_id: image.id } }
    assert_response :no_content
    assert_equal image.id, @event.reload.image_id
  end

  test "update_image with blank image_id clears the photo" do
    @event.update!(image: images(:sanctuary))
    patch image_event_url(@event), params: { event: { image_id: "" } }
    assert_response :no_content
    assert_nil @event.reload.image_id
  end

  test "update_image requires authentication" do
    sign_out
    patch image_event_url(@event), params: { event: { image_id: images(:sanctuary).id } }
    assert_redirected_to new_session_path
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_url
  end
end
