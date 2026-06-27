class Gallery < ApplicationRecord
  has_many :gallery_images, -> { order(position: :asc) }, dependent: :destroy
  has_many :images, through: :gallery_images

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }, allow_blank: true

  scope :published, -> { where(published: true) }
  scope :drafts, -> { where(published: false) }
  scope :ordered, -> { order(created_at: :desc) }

  def cover_image
    images.first
  end
end
