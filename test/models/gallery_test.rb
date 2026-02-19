require "test_helper"

class GalleryTest < ActiveSupport::TestCase
  # Validations -- title

  test "valid with required attributes" do
    gallery = Gallery.new(title: "Test Gallery")
    assert gallery.valid?
  end

  test "invalid without title" do
    gallery = galleries(:worship)
    gallery.title = nil
    assert_not gallery.valid?
    assert_includes gallery.errors[:title], "can't be blank"
  end

  test "invalid with title over 255 characters" do
    gallery = galleries(:worship)
    gallery.title = "a" * 256
    assert_not gallery.valid?
    assert_includes gallery.errors[:title], "is too long (maximum is 255 characters)"
  end

  # Validations -- description

  test "valid with blank description" do
    gallery = Gallery.new(title: "No Description")
    assert gallery.valid?
  end

  test "invalid with description over 2000 characters" do
    gallery = galleries(:worship)
    gallery.description = "a" * 2001
    assert_not gallery.valid?
    assert_includes gallery.errors[:description], "is too long (maximum is 2000 characters)"
  end

  # Scopes

  test "published scope returns only published galleries" do
    published = Gallery.published
    assert_includes published, galleries(:worship)
    assert_includes published, galleries(:community)
    assert_not_includes published, galleries(:draft_gallery)
  end

  test "ordered scope returns galleries newest first" do
    galleries = Gallery.ordered
    assert_equal Gallery.order(created_at: :desc).to_a, galleries.to_a
  end

  # cover_image

  test "cover_image returns the first image by position" do
    gallery = galleries(:worship)
    assert_equal images(:sanctuary), gallery.cover_image
  end

  test "cover_image returns nil when gallery has no images" do
    gallery = galleries(:draft_gallery)
    assert_nil gallery.cover_image
  end

  # Associations

  test "has many gallery_images" do
    assert_respond_to galleries(:worship), :gallery_images
  end

  test "has many images through gallery_images" do
    assert_respond_to galleries(:worship), :images
  end

  test "destroying gallery destroys its gallery_images" do
    gallery = galleries(:worship)
    gallery_image_ids = gallery.gallery_images.pluck(:id)
    assert_not gallery_image_ids.empty?

    gallery.destroy!
    gallery_image_ids.each do |id|
      assert_not GalleryImage.exists?(id)
    end
  end
end
