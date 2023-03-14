class AddDriverToRide < ActiveRecord::Migration[7.0]
  def change
    add_reference :rides, :driver, index: true, foreign_key: true
  end
end
