require "test_helper"
require "webmock/minitest"

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  CLOUDINARY_UPLOAD_RESPONSE = {
    "public_id" => "wbr-pres-cms/uploaded_photo",
    "secure_url" => "https://res.cloudinary.com/dwjulenau/image/upload/wbr-pres-cms/uploaded_photo.jpg",
    "width" => 1200,
    "height" => 800,
    "format" => "jpg",
    "bytes" => 204800
  }.freeze

  setup do
    @user = users(:one)
    @image = images(:sanctuary)
    sign_in_as(@user)

    # Stub all Cloudinary HTTP requests
    stub_request(:post, /api\.cloudinary\.com/).to_return(
      status: 200,
      body: CLOUDINARY_UPLOAD_RESPONSE.to_json,
      headers: { "Content-Type" => "application/json" }
    )
    stub_request(:post, /api\.cloudinary\.com.*destroy/).to_return(
      status: 200,
      body: { "result" => "ok" }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  # Auth tests

  test "index requires authentication" do
    sign_out
    get admin_images_url
    assert_redirected_to new_session_path
  end

  test "new requires authentication" do
    sign_out
    get new_admin_image_url
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    sign_out
    post admin_images_url, params: { file: fixture_file_upload("test_image.jpg", "image/jpeg") }
    assert_redirected_to new_session_path
  end

  test "destroy requires authentication" do
    sign_out
    delete admin_image_url(@image)
    assert_redirected_to new_session_path
  end

  # CRUD tests

  test "should get index" do
    get admin_images_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_image_url
    assert_response :success
  end

  test "should create image via Cloudinary upload" do
    WebMock.stub_request(:post, /api\.cloudinary\.com/).to_return(
      status: 200,
      body: CLOUDINARY_UPLOAD_RESPONSE.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    temp_file = Tempfile.new(["test_image", ".jpg"])
    temp_file.write("fake image data")
    temp_file.rewind

    assert_difference("Image.count") do
      post admin_images_url, params: {
        file: Rack::Test::UploadedFile.new(temp_file.path, "image/jpeg"),
        title: "Test Upload",
        alt_text: "A test image"
      }
    end

    assert_redirected_to admin_images_path
    image = Image.last
    assert_equal "wbr-pres-cms/uploaded_photo", image.cloudinary_public_id
    assert_equal "Test Upload", image.title
  ensure
    temp_file&.close
    temp_file&.unlink
  end

  test "should destroy image" do
    WebMock.stub_request(:post, /api\.cloudinary\.com/).to_return(
      status: 200,
      body: { "result" => "ok" }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    assert_difference("Image.count", -1) do
      delete admin_image_url(@image)
    end

    assert_redirected_to admin_images_url
  end
end
