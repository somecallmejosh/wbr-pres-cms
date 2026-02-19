class CreateImages < ActiveRecord::Migration[8.1]
  def change
    create_table :images do |t|
      t.string :cloudinary_public_id, null: false
      t.string :url, null: false
      t.string :title
      t.string :alt_text
      t.integer :width
      t.integer :height
      t.string :format
      t.integer :bytes

      t.timestamps
    end
    add_index :images, :cloudinary_public_id, unique: true
  end
end
