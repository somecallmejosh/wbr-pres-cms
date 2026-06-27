require "test_helper"

class GalleriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @gallery = galleries(:worship)
    @draft = galleries(:draft_gallery)
  end

  # Auth tests

  test "new requires authentication" do
    sign_out
    get new_gallery_url
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    sign_out
    post galleries_url, params: { gallery: { title: "Unauthorized" } }
    assert_redirected_to new_session_path
  end

  test "edit requires authentication" do
    sign_out
    get edit_gallery_url(@gallery)
    assert_redirected_to new_session_path
  end

  test "update requires authentication" do
    sign_out
    patch gallery_url(@gallery), params: { gallery: { title: "Unauthorized" } }
    assert_redirected_to new_session_path
  end

  test "destroy requires authentication" do
    sign_out
    delete gallery_url(@gallery)
    assert_redirected_to new_session_path
  end

  test "reorder requires authentication" do
    sign_out
    patch reorder_gallery_url(@gallery), params: { ordered_ids: [] }, as: :json
    assert_redirected_to new_session_path
  end

  test "add_image requires authentication" do
    sign_out
    post add_image_gallery_url(@gallery, image_id: images(:sanctuary).id)
    assert_redirected_to new_session_path
  end

  test "remove_image requires authentication" do
    sign_out
    delete remove_image_gallery_url(@gallery, image_id: images(:sanctuary).id)
    assert_redirected_to new_session_path
  end

  # Public access tests

  test "index is publicly accessible" do
    get galleries_url
    assert_response :success
  end

  test "show is publicly accessible" do
    get gallery_url(@gallery)
    assert_response :success
  end

  test "index shows only published galleries to unauthenticated visitors" do
    get galleries_url
    assert_response :success
    assert_match @gallery.title, @response.body
    assert_no_match(/#{Regexp.escape(@draft.title)}/, @response.body)
  end

  test "drafts filter is ignored for unauthenticated visitors" do
    get galleries_url(filter: "drafts")
    assert_response :success
    assert_no_match(/#{Regexp.escape(@draft.title)}/, @response.body)
  end

  test "index shows all galleries (including drafts) to authenticated users" do
    sign_in_as(@user)
    get galleries_url
    assert_response :success
    assert_match @gallery.title, @response.body
    assert_match @draft.title, @response.body
  end

  test "index drafts filter shows only unpublished galleries for admins" do
    sign_in_as(@user)
    get galleries_url(filter: "drafts")
    assert_response :success
    assert_match @draft.title, @response.body
    assert_no_match(/#{Regexp.escape(@gallery.title)}/, @response.body)
  end

  test "index published filter shows only published galleries for admins" do
    sign_in_as(@user)
    get galleries_url(filter: "published")
    assert_response :success
    assert_match @gallery.title, @response.body
    assert_no_match(/#{Regexp.escape(@draft.title)}/, @response.body)
  end

  # CRUD tests

  test "should get new" do
    sign_in_as(@user)
    get new_gallery_url
    assert_response :success
  end

  test "new and edit expose the gallery upload modal entry point" do
    sign_in_as(@user)

    [ new_gallery_url, edit_gallery_url(@gallery) ].each do |url|
      get url
      assert_response :success
      assert_select "#gallery-image-options"
      assert_select "a[data-turbo-frame='upload_modal'][href=?]", new_admin_image_path(picker: "gallery")
      assert_select "turbo-frame#upload_modal"
    end
  end

  test "should create gallery" do
    sign_in_as(@user)
    assert_difference("Gallery.count") do
      post galleries_url, params: { gallery: { title: "New Gallery", description: "A test gallery", published: false } }
    end
    assert_redirected_to gallery_url(Gallery.last)
    assert_equal "New Gallery", Gallery.last.title
  end

  test "should not create gallery with invalid params" do
    sign_in_as(@user)
    assert_no_difference("Gallery.count") do
      post galleries_url, params: { gallery: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should create gallery with images" do
    sign_in_as(@user)
    image = images(:sanctuary)
    assert_difference("GalleryImage.count") do
      post galleries_url, params: {
        gallery: { title: "With Images", published: true },
        image_ids: [ image.id ]
      }
    end
    assert_equal image, Gallery.last.images.first
  end

  test "should get edit" do
    sign_in_as(@user)
    get edit_gallery_url(@gallery)
    assert_response :success
  end

  test "should update gallery" do
    sign_in_as(@user)
    patch gallery_url(@gallery), params: { gallery: { title: "Updated Title" } }
    assert_redirected_to gallery_url(@gallery)
    assert_equal "Updated Title", @gallery.reload.title
  end

  test "should not update gallery with invalid params" do
    sign_in_as(@user)
    patch gallery_url(@gallery), params: { gallery: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update does not modify gallery images" do
    # Image membership is managed live via add_image/remove_image, not on update.
    sign_in_as(@user)
    images_before = @gallery.images.order(:id).to_a

    patch gallery_url(@gallery), params: {
      gallery: { title: "Renamed" },
      image_ids: [ images(:fellowship_hall).id ]
    }

    assert_redirected_to gallery_url(@gallery)
    assert_equal images_before, @gallery.reload.images.order(:id).to_a
  end

  test "should destroy gallery" do
    sign_in_as(@user)
    assert_difference("Gallery.count", -1) do
      delete gallery_url(@gallery)
    end
    assert_redirected_to galleries_url
  end

  test "destroying gallery removes its gallery_images" do
    sign_in_as(@user)
    count_before = @gallery.gallery_images.count
    assert count_before > 0

    assert_difference("GalleryImage.count", -count_before) do
      delete gallery_url(@gallery)
    end
  end

  # Reorder test

  test "reorder updates positions" do
    sign_in_as(@user)
    gi1 = gallery_images(:worship_sanctuary)
    gi2 = gallery_images(:worship_fellowship_hall)

    patch reorder_gallery_url(@gallery),
          params: { ordered_ids: [ gi2.id.to_s, gi1.id.to_s ] },
          as: :json

    assert_response :ok
    assert_equal 0, gi2.reload.position
    assert_equal 1, gi1.reload.position
  end

  # Add image tests

  test "add_image adds an image to the gallery and streams a row" do
    sign_in_as(@user)
    image = images(:sanctuary)

    assert_difference "GalleryImage.count", 1 do
      post add_image_gallery_url(@draft, image_id: image.id), as: :turbo_stream
    end

    assert_response :success
    assert @draft.images.exists?(image.id)
    assert_match "gallery-photo-order", @response.body
  end

  test "add_image is idempotent for an already-added image" do
    sign_in_as(@user)
    image = images(:sanctuary) # already in @gallery via fixtures

    assert_no_difference "GalleryImage.count" do
      post add_image_gallery_url(@gallery, image_id: image.id), as: :turbo_stream
    end

    assert_response :success
  end

  # Remove image tests

  test "remove_image deletes the gallery image by image_id" do
    sign_in_as(@user)
    gi = gallery_images(:worship_sanctuary)

    assert_difference "GalleryImage.count", -1 do
      delete remove_image_gallery_url(@gallery, image_id: gi.image_id),
             as: :turbo_stream
    end

    assert_response :success
    assert_not GalleryImage.exists?(gi.id)
  end

  test "remove_image without turbo_stream redirects to edit" do
    sign_in_as(@user)
    gi = gallery_images(:worship_fellowship_hall)

    delete remove_image_gallery_url(@gallery, image_id: gi.image_id)

    assert_redirected_to edit_gallery_path(@gallery)
    assert_not GalleryImage.exists?(gi.id)
  end
end
