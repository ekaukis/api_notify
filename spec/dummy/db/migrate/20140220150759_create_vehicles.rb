class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :no
      t.string :vin
      t.string :make
      t.integer :dealer_id
      t.string :other

      t.timestamps
    end
  end
end
