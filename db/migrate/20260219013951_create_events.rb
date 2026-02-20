class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.date :event_date, null: false
      t.time :start_time, null: false
      t.time :end_time
      t.string :location
      t.string :category, null: false

      t.timestamps
    end

    add_index :events, :event_date
    add_index :events, :category
    add_index :events, [ :event_date, :category ]
  end
end
