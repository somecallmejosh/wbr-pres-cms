class GalleriesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_gallery, only: %i[show edit update destroy reorder]

  def index
    @galleries = Gallery.ordered
  end

  def show
    @gallery_images = @gallery.gallery_images.includes(:image)
  end

  def new
    @gallery = Gallery.new
    @images = Image.order(created_at: :desc)
  end

  def create
    @gallery = Gallery.new(gallery_params)

    if @gallery.save
      sync_images(@gallery, params[:image_ids] || [])
      redirect_to @gallery, notice: "Gallery was successfully created."
    else
      @images = Image.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @images = Image.order(created_at: :desc)
    @gallery_images = @gallery.gallery_images.includes(:image)
  end

  def update
    if @gallery.update(gallery_params)
      sync_images(@gallery, params[:image_ids] || [])
      redirect_to @gallery, notice: "Gallery was successfully updated."
    else
      @images = Image.order(created_at: :desc)
      @gallery_images = @gallery.gallery_images.includes(:image)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gallery.destroy!
    redirect_to galleries_path, notice: "Gallery was successfully deleted.", status: :see_other
  end

  def reorder
    ordered_ids = params[:ordered_ids] || []
    GalleryImage.transaction do
      ordered_ids.each_with_index do |id, index|
        GalleryImage.where(id: id, gallery: @gallery).update_all(position: index)
      end
    end
    head :ok
  end

  private

  def set_gallery
    @gallery = Gallery.find(params[:id])
  end

  def gallery_params
    params.expect(gallery: [ :title, :description, :published ])
  end

  def sync_images(gallery, image_ids)
    image_ids = Array(image_ids).map(&:to_i).reject(&:zero?)
    existing_image_ids = gallery.gallery_images.pluck(:image_id)

    gallery.gallery_images.where.not(image_id: image_ids).destroy_all

    (image_ids - existing_image_ids).each do |image_id|
      gallery.gallery_images.create!(image_id: image_id)
    end
  end
end
