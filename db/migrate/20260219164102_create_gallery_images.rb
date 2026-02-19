class CreateGalleryImages < ActiveRecord::Migration[8.1]
  def change
    create_table :gallery_images do |t|
      t.references :gallery, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :gallery_images, [:gallery_id, :image_id], unique: true
    add_index :gallery_images, [:gallery_id, :position]
  end
end
