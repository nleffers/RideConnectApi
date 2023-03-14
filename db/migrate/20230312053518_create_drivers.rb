class CreateDrivers < ActiveRecord::Migration[7.0]
  def change
    create_table :drivers do |t|
      t.string :home_address
      t.string :home_city
      t.string :home_state
      t.string :home_zip
      t.string :home_latitude
      t.string :home_longitude

      t.timestamps
    end
  end
end
