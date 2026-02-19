class GalleryImage < ApplicationRecord
  belongs_to :gallery
  belongs_to :image

  validates :image_id, uniqueness: { scope: :gallery_id }

  before_create :set_default_position

  private

  def set_default_position
    self.position = gallery.gallery_images.maximum(:position).to_i + 1
  end
end
