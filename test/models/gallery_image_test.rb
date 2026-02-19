require "test_helper"

class GalleryImageTest < ActiveSupport::TestCase
  # Validations -- uniqueness

  test "invalid when the same image is added to the same gallery twice" do
    existing = gallery_images(:worship_sanctuary)
    duplicate = GalleryImage.new(gallery: existing.gallery, image: existing.image)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:image_id], "has already been taken"
  end

  test "the same image can appear in different galleries" do
    image = images(:sanctuary)
    other_gallery = galleries(:community)
    gallery_image = GalleryImage.new(gallery: other_gallery, image: image)
    assert gallery_image.valid?
  end

  # Default position callback

  test "position is set automatically on create" do
    gallery = galleries(:community)
    # community gallery has no images in fixtures, so position should start at 1
    gi = gallery.gallery_images.create!(image: images(:sanctuary))
    assert_equal 1, gi.position
  end

  test "position increments from the current maximum" do
    gallery = galleries(:worship)
    # worship gallery has images at positions 1 and 2
    max = gallery.gallery_images.maximum(:position)
    new_gi = gallery.gallery_images.create!(image_id: create_unique_image.id)
    assert_equal max + 1, new_gi.position
  end

  # Associations

  test "belongs to gallery" do
    assert_respond_to gallery_images(:worship_sanctuary), :gallery
  end

  test "belongs to image" do
    assert_respond_to gallery_images(:worship_sanctuary), :image
  end

  private

  def create_unique_image
    Image.create!(
      cloudinary_public_id: "wbr-pres-cms/test_#{SecureRandom.hex(4)}",
      url: "https://res.cloudinary.com/dwjulenau/image/upload/test.jpg"
    )
  end
end
