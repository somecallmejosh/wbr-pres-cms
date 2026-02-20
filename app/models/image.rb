class Image < ApplicationRecord
  has_many :events, dependent: :nullify
  has_many :gallery_images, dependent: :destroy
  has_many :galleries, through: :gallery_images

  validates :cloudinary_public_id, presence: true, uniqueness: true
  validates :url, presence: true
  validates :title, length: { maximum: 255 }, allow_blank: true
  validates :alt_text, length: { maximum: 255 }, allow_blank: true

  def thumbnail_url(width: 200, height: 200)
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: width, height: height, crop: :fill, gravity: "face", quality: :auto, fetch_format: :auto, dpr: :auto
    )
  end

  def display_url(width: 800)
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: width, crop: :limit, quality: :auto, fetch_format: :auto
    )
  end
end
