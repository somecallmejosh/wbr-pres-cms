class CreateMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :members do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :phone
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zip_code
      t.date :date_of_birth

      t.timestamps
    end

    add_index :members, [:last_name, :first_name]
    add_index :members, :date_of_birth
  end
end
