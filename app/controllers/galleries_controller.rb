class GalleriesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_gallery, only: %i[show edit update destroy reorder add_image remove_image]

  def index
    # Admins can filter by status; the public only ever sees published galleries,
    # so the filter param is ignored for unauthenticated visitors.
    @filter = params[:filter].presence_in(%w[published drafts])
    @galleries =
      if authenticated?
        case @filter
        when "published" then Gallery.published.ordered
        when "drafts"    then Gallery.drafts.ordered
        else                  Gallery.ordered
        end
      else
        Gallery.published.ordered
      end
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
    # Image membership is managed live via add_image/remove_image, so update
    # only touches the gallery's own attributes.
    if @gallery.update(gallery_params)
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

  # Adds an image to the gallery (idempotent) and streams a new row into the
  # "Photos in this gallery" list. Driven live by the picker checkboxes.
  def add_image
    @image = Image.find(params[:image_id])
    @gallery_image = @gallery.gallery_images.find_or_create_by!(image: @image)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_gallery_path(@gallery) }
    end
  end

  # Removes an image from this gallery (the Image itself stays in the library).
  def remove_image
    @gallery.gallery_images.where(image_id: params[:image_id]).destroy_all

    respond_to do |format|
      # 204 lets the client (gallery_editor) own the fade-out animation.
      format.turbo_stream { head :no_content }
      format.html { redirect_to edit_gallery_path(@gallery), notice: "Image removed from gallery." }
    end
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
