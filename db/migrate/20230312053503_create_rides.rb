class CreateRides < ActiveRecord::Migration[7.0]
  def change
    create_table :rides do |t|
      t.string :start_address
      t.string :start_city
      t.string :start_state
      t.string :start_zip
      t.string :start_latitude
      t.string :start_longitude
      t.string :destination_address
      t.string :destination_city
      t.string :destination_state
      t.string :destination_zip
      t.string :destination_latitude
      t.string :destination_longitude

      t.timestamps
    end
  end
end
