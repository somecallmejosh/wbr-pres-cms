class CreateGalleries < ActiveRecord::Migration[8.1]
  def change
    create_table :galleries do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :published, null: false, default: false

      t.timestamps
    end

    add_index :galleries, :published
  end
end
